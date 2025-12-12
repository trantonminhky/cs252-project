import torch
import chromadb
from chromadb.utils.embedding_functions import SentenceTransformerEmbeddingFunction
from sentence_transformers import CrossEncoder
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any, List
import time
from contextlib import asynccontextmanager
# --- NEW IMPORTS FOR HYBRID SEARCH ---
from rank_bm25 import BM25Okapi
import string

# --- 1. CONFIGURATION & MODEL LOADING ---
print("Loading models... (This may take a moment)")

ef = SentenceTransformerEmbeddingFunction(
    model_name="BAAI/bge-m3", 
    device="cuda"
)

reranker = CrossEncoder(
    "E:/rr_model", 
    device="cuda", 
    model_kwargs={"dtype": "float16"}
)

print("Warming up GPU...")
reranker.predict([["warmup", "warmup"]])
print("Models loaded and warmed up!")

# --- 2. DATABASE SETUP ---
client = chromadb.PersistentClient(path="./vector_db")
collection = client.get_collection(
    name='ct_data',
    embedding_function=ef
)

# --- 3. GLOBAL BM25 INDEX (Hybrid Search) ---
# We need to load documents into memory to build the keyword index.
# In a massive production system, you would use Elasticsearch/Solr, 
# but for local apps, this is perfect.
bm25_index = None
doc_id_map = {}   # Maps BM25 index integer -> ChromaDB Document ID
all_metadatas = {} # Cache metadata for fast lookup after BM25 retrieval

def build_bm25_index():
    global bm25_index, doc_id_map, all_metadatas
    print("Building BM25 Index from ChromaDB...")
    
    # Get all documents (Limit helps if DB is huge, but we need all for search)
    # Note: If your DB has millions of rows, pagination is needed here.
    data = collection.get() 
    
    documents = data['documents']
    ids = data['ids']
    metas = data['metadatas']

    # Simple tokenizer: lowercase and remove punctuation
    tokenized_corpus = [
        doc.lower().translate(str.maketrans('', '', string.punctuation)).split() 
        for doc in documents
    ]

    bm25_index = BM25Okapi(tokenized_corpus)
    
    # Map array index to Document ID and Metadata
    for idx, (doc_id, meta, doc_text) in enumerate(zip(ids, metas, documents)):
        doc_id_map[idx] = doc_id
        all_metadatas[doc_id] = {
            "meta": meta,
            "document": doc_text
        }
        
    print(f"BM25 Index built with {len(documents)} documents.")

# --- NEW LIFESPAN HANDLER ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    # --- STARTUP LOGIC ---
    print("Executing startup logic...")
    build_bm25_index()
    
    yield  # The application runs while yielding
    
    # --- SHUTDOWN LOGIC (Optional) ---
    print("Executing shutdown logic...")
    # You could close DB connections or clear GPU memory here if needed
    # e.g., del reranker
# --- 4. FASTAPI APP ---
app = FastAPI(title="Hybrid Search API (RAG Pre-stage)",lifespan=lifespan)



class SearchRequest(BaseModel):
    query: str
    final_k: int = 3
    initial_k: int = 10  # Number of candidates to fetch from EACH source (Vector & BM25)
    filters: Optional[Dict[str, Any]] = None 
    alpha: float = 0.5   # Weight for vector search (0.0 = Pure Keyword, 1.0 = Pure Vector)

# --- HELPER: RECURSIVE FILTER CLEANING ---
def clean_filters_recursive(node: Any) -> Any:
    if isinstance(node, dict):
        cleaned_dict = {k: clean_filters_recursive(v) for k, v in node.items()}
        # Remove None values
        cleaned_dict = {k: v for k, v in cleaned_dict.items() if v is not None}
        return cleaned_dict if cleaned_dict else None
    elif isinstance(node, list):
        cleaned_list = [clean_filters_recursive(item) for item in node]
        cleaned_list = [item for item in cleaned_list if item is not None]
        return cleaned_list if cleaned_list else None
    elif isinstance(node, str):
        return node if node.strip() != "" else None
    else:
        return node

# --- HELPER: RECIPROCAL RANK FUSION (RRF) ---
def reciprocal_rank_fusion(vector_results, bm25_results, k=60):
    """
    Combines two lists of results based on their rank.
    RRF Score = 1 / (k + rank)
    """
    fused_scores = {}
    
    # Process Vector Results
    for rank, doc_id in enumerate(vector_results):
        if doc_id not in fused_scores:
            fused_scores[doc_id] = 0
        fused_scores[doc_id] += 1 / (k + rank)
        
    # Process BM25 Results
    for rank, doc_id in enumerate(bm25_results):
        if doc_id not in fused_scores:
            fused_scores[doc_id] = 0
        fused_scores[doc_id] += 1 / (k + rank)
    
    # Sort by fused score descending
    sorted_doc_ids = sorted(fused_scores.keys(), key=lambda x: fused_scores[x], reverse=True)
    return sorted_doc_ids

# --- 5. ENDPOINTS ---
@app.post("/search")
async def search_locations(request: SearchRequest):
    try:
        start_time = time.perf_counter()
        target_filters = clean_filters_recursive(request.filters)

        # --- A. VECTOR SEARCH (Semantic) ---
        vector_results_obj = collection.query(
            query_texts=[request.query],
            n_results=request.initial_k,
            where=target_filters
        )
        # Extract IDs for fusion
        vector_ids = vector_results_obj['ids'][0] if vector_results_obj['ids'] else []

        # --- B. BM25 SEARCH (Keyword) ---
        # Tokenize query
        tokenized_query = request.query.lower().translate(str.maketrans('', '', string.punctuation)).split()
        
        # Get scores for all docs, then sort to get top N
        # (BM25Okapi doesn't natively support "filters", so we search globally and intersect later 
        # or just rely on Reranker to filter out irrelevant ones. 
        # Here we get Top K raw keywords.)
        bm25_scores = bm25_index.get_scores(tokenized_query)
        top_bm25_indices =  bm25_scores.argsort()[::-1][:request.initial_k]
        
        bm25_ids = []
        for idx in top_bm25_indices:
            # Only include if score > 0 (at least one keyword matched)
            if bm25_scores[idx] > 0:
                doc_id = doc_id_map[idx]
                # OPTIONAL: Apply filters strictly to BM25 results here if needed
                # For now, we assume Vector Filters are strict, BM25 is additive.
                bm25_ids.append(doc_id)

        # --- C. FUSION (RRF) ---
        # Combine the IDs from both methods
        fused_ids = reciprocal_rank_fusion(vector_ids, bm25_ids)
        
        # Limit to reasonable amount for Reranker (e.g. top 20 fused)
        candidates_ids = fused_ids[:request.initial_k * 2]

        if not candidates_ids:
             return {"data": [], "meta": {"count": 0}}

        # --- D. FETCH DATA FOR RERANKER ---
        # We need the actual text for the reranker. 
        # We use our in-memory cache 'all_metadatas' or query Chroma by ID.
        candidate_docs = []
        candidate_metas = []
        
        for doc_id in candidates_ids:
            # Retrieve from cache if available, or fallback to Chroma
            if doc_id in all_metadatas:
                candidate_docs.append(all_metadatas[doc_id]['document'])
                candidate_metas.append(all_metadatas[doc_id]['meta'])
            else:
                # Fallback (shouldn't happen if cache is fresh)
                data = collection.get(ids=[doc_id])
                candidate_docs.append(data['documents'][0])
                candidate_metas.append(data['metadatas'][0])

        # --- E. RERANKING ---
        pairs = [[request.query, doc] for doc in candidate_docs]
        scores = reranker.predict(pairs)

        combined_results = list(zip(scores, candidate_docs, candidate_metas))
        combined_results.sort(key=lambda x: x[0], reverse=True)

        # --- F. FORMATTING ---
        formatted_results = []
        for score, doc, meta in combined_results:
            if len(formatted_results) >= request.final_k:
                break
            
            item = {
                "name": meta.get('name', 'Unknown'),
                "description": doc,
                "image_link": meta.get('image link', ''),
                "relevance_score": float(score),
                "source": "Hybrid", # Just a tag
                "building_type": meta.get('building_type', 'unknown'),
                # ... add other fields
            }
            formatted_results.append(item)

        total_time = time.perf_counter() - start_time

        return {
            "data": formatted_results,
            "meta": {
                "query": request.query,
                "vector_candidates": len(vector_ids),
                "bm25_candidates": len(bm25_ids),
                "results_returned": len(formatted_results),
                "time_taken_seconds": f"{total_time:.4f}"
            }
        }

    except Exception as e:
        print(f"Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))