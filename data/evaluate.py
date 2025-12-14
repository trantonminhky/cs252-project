import json
import time
import torch
import numpy as np
import pandas as pd
from tqdm import tqdm
import chromadb
from chromadb.utils.embedding_functions import SentenceTransformerEmbeddingFunction
from sentence_transformers import CrossEncoder

# --- CONFIGURATION ---
# Path to the file you just generated
TEST_DATASET = "cultural_test_dataset.json"

# Database Configuration (Must match your ingestion setup)
CHROMA_PATH = "./vector_db"
COLLECTION_NAME = "ct_data"

# Model Configuration
EMBED_MODEL = "BAAI/bge-m3"
# Use your local path "E:/rr_model" if you have it, otherwise "BAAI/bge-reranker-v2-m3"
RERANK_MODEL = "E:/rr_model" 
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# Evaluation Settings
INITIAL_K = 20  # How many docs to retrieve from ChromaDB
FINAL_K = 5     # How many docs to show the user after reranking

def calculate_metrics(retrieved_ids, relevant_ids, k):
    """
    Calculates Hit Rate (Recall) and MRR for a list of retrieved IDs.
    """
    # Cut off at K
    candidates = retrieved_ids[:k]
    relevant_set = set(relevant_ids)
    
    # 1. Hit Rate (Accuracy)
    is_hit = any(doc_id in relevant_set for doc_id in candidates)
    
    # 2. MRR (Ranking Quality)
    mrr = 0.0
    for i, doc_id in enumerate(candidates):
        if doc_id in relevant_set:
            mrr = 1.0 / (i + 1)
            break
            
    return is_hit, mrr

def run_evaluation():
    print(f"🚀 Starting Cultural Evaluation on {DEVICE}...")
    
    # 1. Load Test Data
    print(f"📂 Loading {TEST_DATASET}...")
    try:
        with open(TEST_DATASET, "r", encoding="utf-8") as f:
            test_cases = json.load(f)
    except FileNotFoundError:
        print("❌ Error: Test file not found. Run generate_cultural_tests.py first.")
        return

    # 2. Load Models
    print("⚙️  Loading Models...")
    ef = SentenceTransformerEmbeddingFunction(model_name=EMBED_MODEL, device=DEVICE)
    # Note: automodel_args is deprecated in newer versions, using model_kwargs if needed
    reranker = CrossEncoder(RERANK_MODEL, device=DEVICE, model_kwargs={"dtype": "float16"})

    # 3. Connect to Database
    print("🔌 Connecting to ChromaDB...")
    client = chromadb.PersistentClient(path=CHROMA_PATH)
    collection = client.get_collection(name=COLLECTION_NAME, embedding_function=ef)
    print(f"   Database contains {collection.count()} documents.")

    # 4. Run Queries
    results = []
    print(f"🧪 Evaluating {len(test_cases)} queries...")
    
    # Track latencies
    retrieval_times = []
    rerank_times = []

    for case in tqdm(test_cases):
        query = case["query"]
        ground_truth_ids = case["relevant_ids"]
        
        # --- STAGE 1: RETRIEVAL (ChromaDB) ---
        t0 = time.perf_counter()
        
        retrieval = collection.query(
            query_texts=[query],
            n_results=INITIAL_K
        )
        
        t1 = time.perf_counter()
        retrieval_times.append(t1 - t0)
        
        # Extract IDs and Documents
        # Chroma returns lists of lists (for batch queries), we take [0]
        retrieved_ids = retrieval['ids'][0]
        retrieved_docs = retrieval['documents'][0]
        
        # Calculate Stage 1 Metrics (Baseline)
        hit_stage1, mrr_stage1 = calculate_metrics(retrieved_ids, ground_truth_ids, k=FINAL_K)

        # --- STAGE 2: RERANKING (Cross-Encoder) ---
        if retrieved_docs:
            t2 = time.perf_counter()
            
            # Create pairs for reranker: [[query, doc1], [query, doc2], ...]
            pairs = [[query, doc] for doc in retrieved_docs]
            scores = reranker.predict(pairs)
            
            # Zip (ID, Score) and sort by Score Descending
            ranked_results = list(zip(retrieved_ids, scores))
            ranked_results.sort(key=lambda x: x[1], reverse=True)
            
            # Extract just the IDs in new order
            reranked_ids = [r[0] for r in ranked_results]
            
            t3 = time.perf_counter()
            rerank_times.append(t3 - t2)
            
            # Calculate Stage 2 Metrics (Final)
            hit_stage2, mrr_stage2 = calculate_metrics(reranked_ids, ground_truth_ids, k=FINAL_K)
        else:
            # Handle empty retrieval
            hit_stage2, mrr_stage2 = 0, 0.0
            reranked_ids = []

        # Store results
        results.append({
            "query": query,
            "hit_1": hit_stage1, "mrr_1": mrr_stage1, # Stage 1 (Vector Only)
            "hit_2": hit_stage2, "mrr_2": mrr_stage2  # Stage 2 (Reranked)
        })

    # 5. Final Report
    df_res = pd.DataFrame(results)
    
    print("\n" + "="*50)
    print(f"📊 EVALUATION REPORT (Top-{FINAL_K})")
    print("="*50)
    
    print("STAGE 1: Vector Search Only (ChromaDB)")
    print(f"   ✅ Recall: {df_res['hit_1'].mean():.2%}")
    print(f"   🎯 MRR:    {df_res['mrr_1'].mean():.4f}")
    print(f"   ⚡ Latency: {np.mean(retrieval_times)*1000:.2f} ms")
    
    print("\nSTAGE 2: Reranked (Vector + Cross-Encoder)")
    print(f"   ✅ Recall: {df_res['hit_2'].mean():.2%}")
    print(f"   🎯 MRR:    {df_res['mrr_2'].mean():.4f}")
    print(f"   ⚡ Latency: {np.mean(rerank_times)*1000:.2f} ms (Reranking Only)")
    
    print("-" * 50)
    print(f"🚀 MRR IMPROVEMENT: {(df_res['mrr_2'].mean() - df_res['mrr_1'].mean()) / df_res['mrr_1'].mean():.2%} boost from reranker")
    print("="*50)

    # 6. Save Failures for Analysis
    failures = df_res[df_res['hit_2'] == 0]
    if not failures.empty:
        print(f"\n📝 Saved {len(failures)} failed queries to 'failed_cases.csv' for review.")
        failures.to_csv("failed_cases.csv", index=False)

if __name__ == "__main__":
    run_evaluation()