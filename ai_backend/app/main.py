from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import recommendation

app = FastAPI(
    title="Vietnamese Heritage Recommendation API",
    description="A Zero-Shot RL system for evolving architectural preferences.",
    version="1.0"
)

# Allow your team (frontend) to call this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register the router
app.include_router(recommendation.router, prefix="/api/v1", tags=["recommendation"])

@app.get("/")
def health_check():
    return {"status": "active", "system": "Heritage RecSys v1"}

if __name__ == "__main__":
    import uvicorn
    # Run the server on port 8000
    uvicorn.run(...)