import torch
import chromadb
from chromadb.utils.embedding_functions import SentenceTransformerEmbeddingFunction
from sentence_transformers import CrossEncoder
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any, Union, List
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
    final_k: int = 3
    initial_k: int = 10
    filters: Optional[Dict[str, Any]] = None 

# --- HELPER FUNCTION ---
def clean_filters_recursive(node: Any) -> Any:
    """
    Recursively removes empty strings, empty lists, and empty dicts.
    Returns None if the resulting structure effectively implies 'no filter'.
    """
    if isinstance(node, dict):
        cleaned_dict = {}
        for k, v in node.items():
            cleaned_v = clean_filters_recursive(v)
            if cleaned_v is not None:
                cleaned_dict[k] = cleaned_v
        return cleaned_dict if cleaned_dict else None
    
    elif isinstance(node, list):
        cleaned_list = []
        for item in node:
            cleaned_item = clean_filters_recursive(item)
            if cleaned_item is not None:
                cleaned_list.append(cleaned_item)
        return cleaned_list if cleaned_list else None
    
    elif isinstance(node, str):
        # Treat empty strings as 'remove me'
        return node if node.strip() != "" else None
    
    else:
        # Keep numbers, booleans, etc.
        return node

# --- 4. ENDPOINTS ---
@app.post("/search")
async def search_locations(request: SearchRequest):
    try:
        start_time = time.perf_counter()

        # --- NEW LOGIC START ---
        # Recursively clean the filters. 
        # If the result is None (e.g. {"$and": [{"a": {"$in": [""]}}]} -> None), 
        # then ChromaDB will search without filters.
        target_filters = clean_filters_recursive(request.filters)
        # --- NEW LOGIC END ---

        # Step A: Initial Retrieval
        results = collection.query(
            query_texts=[request.query],
            n_results=request.initial_k,
            where=target_filters  # Pass the cleaned filters (or None)
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

        # Step C: Formatting
        formatted_results = []
        
        for score, doc, meta in combined_results:
            if len(formatted_results) >= request.final_k:
                break
            
            item = {
                "name": meta.get('name', 'Unknown'),
                "description": doc,
                "image_link": meta.get('image link', ''),
                "relevance_score": float(score),
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
                "filters_used": target_filters, # Return what was actually used
                "time_taken_seconds": f"{total_time:.4f}"
            }
        }

    except Exception as e:
        print(f"Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
def health_check():
    return {"status": "ok", "model": "bge-m3 + bge-reranker-v2-m3", "device": "cuda"}