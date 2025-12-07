import torch
import chromadb
from chromadb.utils.embedding_functions import SentenceTransformerEmbeddingFunction
from sentence_transformers import CrossEncoder
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any
import time

# --- 1. CONFIGURATION & MODEL LOADING ---
print("Loading models... (This may take a moment)")

# A. Embedding Function
ef = SentenceTransformerEmbeddingFunction(
    model_name="BAAI/bge-m3", 
    device="cuda"
)

# B. Reranker Model
reranker = CrossEncoder(
    "E:/rr_model", 
    device="cuda", 
    model_kwargs={"dtype": "float16"}
)

# C. Warmup
print("Warming up GPU...")
reranker.predict([["warmup", "warmup"]])
print("Models loaded and warmed up!")

# --- 2. DATABASE SETUP ---
client = chromadb.PersistentClient(path="./vector_db")
collection = client.get_collection(
    name='ct_data',
    embedding_function=ef
)

# --- 3. FASTAPI APP & DATA MODELS ---
app = FastAPI(title="Reranked Search API")

class SearchRequest(BaseModel):
    query: str
    final_k: int = 3      # How many results to return to the user
    initial_k: int = 10   # How many candidates to fetch from DB before reranking
    
    # NEW: Accepts a dictionary for ChromaDB filtering 
    # Example: {"building_type": "restaurant"} or {"$and": [...]}
    filters: Optional[Dict[str, Any]] = None 

# --- 4. ENDPOINTS ---

@app.post("/search")
async def search_locations(request: SearchRequest):
    try:
        start_time = time.perf_counter()

        # Step A: Initial Retrieval with Metadata Filtering
        # We pass 'where=request.filters' directly to ChromaDB
        results = collection.query(
            query_texts=[request.query],
            n_results=request.initial_k,
            where=request.filters 
        )

        retrieved_docs = results['documents'][0]
        retrieved_metas = results['metadatas'][0]

        # Handle case with no results
        if not retrieved_docs:
            return {
                "data": [], 
                "meta": {
                    "query": request.query,
                    "count": 0,
                    "time_taken_seconds": 0
                }
            }

        # Step B: Reranking
        pairs = [[request.query, doc] for doc in retrieved_docs]
        scores = reranker.predict(pairs)

        # Zip and Sort
        combined_results = list(zip(scores, retrieved_docs, retrieved_metas))
        combined_results.sort(key=lambda x: x[0], reverse=True)

        # Step C: Formatting (Threshold Removed)
        formatted_results = []
        
        for score, doc, meta in combined_results:
            # Stop if we have enough results
            if len(formatted_results) >= request.final_k:
                break
            
            # (Threshold check deleted here)

            item = {
                "name": meta.get('name', 'Unknown'),
                "description": doc,
                "image_link": meta.get('image link', ''),
                "relevance_score": float(score),
                # Optional: Return type to verify filtering worked
                "building_type": meta.get('building_type', 'unknown'), 
                "arch_style": meta.get('arch_style', 'unknown'),
                "religion": meta.get('religion', 'unknown'),
                "food_type": meta.get('food_type', 'unknown')
            }
            formatted_results.append(item)

        total_time = time.perf_counter() - start_time

        return {
            "data": formatted_results,
            "meta": {
                "query": request.query,
                "candidates_reranked": len(retrieved_docs),
                "results_returned": len(formatted_results),
                "filters_used": request.filters,
                "time_taken_seconds": f"{total_time:.4f}"
            }
        }

    except Exception as e:
        print(f"Error: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/")
def health_check():
    return {"status": "ok", "model": "bge-m3 + bge-reranker-v2-m3", "device": "cuda"}