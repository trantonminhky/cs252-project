import gradio as gr
import chromadb
from chromadb.utils.embedding_functions import SentenceTransformerEmbeddingFunction
from sentence_transformers import CrossEncoder
import torch
from rank_bm25 import BM25Okapi
import string
import os
import sys

# --- 1. SETUP & MODEL LOADING ---
print("⏳ Loading models...")

# Detect Hardware (GPU vs CPU)
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Running on: {device}")

# Embedding Function (Must match what you used to create the DB)
ef = SentenceTransformerEmbeddingFunction(
    model_name="BAAI/bge-m3",
    device=device
)

# Reranker Model
reranker = CrossEncoder(
    "BAAI/bge-reranker-v2-m3",
    device=device,
    trust_remote_code=True,
    model_kwargs={"dtype": "float16"} if device == "cuda" else {}
)

print("✅ Models loaded!")

# --- 2. LOAD PERSISTENT VECTOR DB ---
DB_PATH = "./vector_db"  # This must match the folder name you uploaded

if not os.path.exists(DB_PATH):
    print(f"❌ Error: The folder '{DB_PATH}' was not found in the Space.")
    print("Please upload your local 'vector_db' folder to the Files tab.")
    # We don't exit here so you can see the error in logs, but the app will fail later.
else:
    print(f"wd: {os.getcwd()}") # Print working directory for debugging

# Initialize Persistent Client
client = chromadb.PersistentClient(path=DB_PATH)

# Get the existing collection
# Note: We use get_collection because we assume it already exists.
try:
    collection = client.get_collection(name='ct_data', embedding_function=ef)
    print(f"✅ Loaded collection 'ct_data' with {collection.count()} documents.")
except Exception as e:
    print(f"❌ Error loading collection: {e}")
    # Fallback for debugging if name is wrong
    print(f"Available collections: {[c.name for c in client.list_collections()]}")
    sys.exit(1)

# --- 3. BUILD IN-MEMORY INDICES (BM25) ---
# We need to fetch all documents from the DB to build the BM25 index 
# and the metadata cache. This avoids needing the CSV files.

bm25_index = None
doc_id_map = {}
all_metadatas = {}

def build_indices_from_db():
    global bm25_index, doc_id_map, all_metadatas
    
    print("⏳ Fetching data from ChromaDB to build BM25 index...")
    
    # Fetch all data (IDs, Documents, Metadatas)
    # If you have >100k docs, you might want to paginate this, but for typical RAG it's fine.
    data = collection.get()
    
    ids = data['ids']
    documents = data['documents']
    metadatas = data['metadatas']
    
    if not documents:
        print("⚠️ Warning: Collection is empty!")
        return

    # Build BM25 Corpus
    print(f"Processing {len(documents)} documents for Keyword Search...")
    tokenized_corpus = [
        doc.lower().translate(str.maketrans('', '', string.punctuation)).split()
        for doc in documents
    ]
    bm25_index = BM25Okapi(tokenized_corpus)
    
    # Reconstruct Cache
    for idx, (doc_id, doc_text, meta) in enumerate(zip(ids, documents, metadatas)):
        # Map integer index (from BM25) back to string ID
        doc_id_map[idx] = doc_id
        
        # Store in fast lookup dict
        all_metadatas[doc_id] = {
            "document": doc_text,
            "meta": meta if meta else {}
        }
        
    print("✅ Hybrid Index Ready.")

# Run this immediately
build_indices_from_db()

# --- 4. SEARCH LOGIC ---
def reciprocal_rank_fusion(vector_results, bm25_results, k=60):
    fused_scores = {}
    for rank, doc_id in enumerate(vector_results):
        fused_scores[doc_id] = fused_scores.get(doc_id, 0) + (1 / (k + rank))
    for rank, doc_id in enumerate(bm25_results):
        fused_scores[doc_id] = fused_scores.get(doc_id, 0) + (1 / (k + rank))
    return sorted(fused_scores.keys(), key=lambda x: fused_scores[x], reverse=True)

def granular_search(query: str, initial_k: int = 15, final_k: int = 3):
    try:
        # A. Vector Search
        # Querying the persistent DB
        vec_res = collection.query(query_texts=[query], n_results=initial_k)
        vector_ids = vec_res['ids'][0] if vec_res['ids'] else []

        # B. BM25 Search
        bm25_ids = []
        if bm25_index:
            tokenized = query.lower().translate(str.maketrans('', '', string.punctuation)).split()
            scores = bm25_index.get_scores(tokenized)
            top_indices = scores.argsort()[::-1][:initial_k]
            bm25_ids = [doc_id_map[i] for i in top_indices if scores[i] > 0]

        # C. Fusion
        candidates_ids = reciprocal_rank_fusion(vector_ids, bm25_ids)[:initial_k]
        
        if not candidates_ids:
            return {"data": [], "message": "No results found"}

        # D. Fetch Text (from Cache)
        docs = []
        metas = []
        for did in candidates_ids:
            item = all_metadatas.get(did)
            if item:
                docs.append(item['document'])
                metas.append(item['meta'])

        # E. Rerank
        if not docs:
            return {"data": []}

        pairs = [[query, doc] for doc in docs]
        scores = reranker.predict(pairs)
        
        # F. Format
        results = sorted(zip(scores, docs, metas), key=lambda x: x[0], reverse=True)[:final_k]
        
        formatted_data = []
        for score, doc, meta in results:
            formatted_data.append({
                "name": meta.get('name', 'Unknown'),
                "description": doc,
                "image_id": meta.get('image id', ''),
                "relevance_score": float(score),
                "building_type": meta.get('building_type', 'unknown')
            })

        return {
            "data": formatted_data,
            "meta": {
                "query": query,
                "count": len(formatted_data)
            }
        }

    except Exception as e:
        return {"error": str(e)}

# --- 5. GRADIO UI ---
demo = gr.Interface(
    fn=granular_search,
    inputs=[
        gr.Textbox(label="Query", placeholder="Search for Vietnamese architecture..."),
        gr.Number(value=15, label="Initial K", visible=False),
        gr.Number(value=3, label="Final K", visible=False)
    ],
    outputs=gr.JSON(label="Results"),
    title="Granular Search API (Persistent)",
    allow_flagging="never"
)

if __name__ == "__main__":
    demo.queue().launch(server_name="0.0.0.0", server_port=7860)