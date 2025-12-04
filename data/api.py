import chromadb
from chromadb.utils.embedding_functions import SentenceTransformerEmbeddingFunction
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

# --- 1. Initialize App & Database ---
app = FastAPI(title="Filter Search API")

client = chromadb.PersistentClient(path="./vector_db")

# Same embedding function as before
ef = SentenceTransformerEmbeddingFunction(
    model_name="sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2",
    device="cuda" # Change to "cpu" if running on a server without GPU
)

# Get the existing collection
collection = client.get_collection(name="ct_data", embedding_function=ef)

# --- 2. Define Data Model ---
class SearchRequest(BaseModel):
    query: str
    limit: int = 3

# --- 3. Create Search Endpoint ---
@app.post("/search")
async def search_locations(request: SearchRequest):
    try:
        results = collection.query(
            query_texts=[request.query],
            n_results=request.limit
        )
        
        # Format the output to be clean JSON
        formatted_results = []
        if results['documents']:
            for i in range(len(results['documents'][0])):
                item = {
                    "name": results['metadatas'][0][i].get('name'),
                    "description": results['documents'][0][i],
                    "image_link": results['metadatas'][0][i].get('image link', ''),
                    "score": results['distances'][0][i] if results['distances'] else 0
                }
                formatted_results.append(item)
                
        return {"data": formatted_results}

    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/")
def health_check():
    return {"status": "200", "message": "Filter search API is running"}