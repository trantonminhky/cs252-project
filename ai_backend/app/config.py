import os
from pathlib import Path

class Settings:
    PROJECT_NAME: str = "Recommendation System"
    VERSION: str = "1.0.0"
    
    # Paths
    BASE_DIR = Path(__file__).resolve().parent.parent
    DATA_DIR = BASE_DIR / "data"
    RAW_DATA_PATH = DATA_DIR / "raw" / "architecture.csv"
    PROCESSED_DATA_PATH = DATA_DIR / "processed" / "item_embeddings.pkl"

    # RL Hyperparameters (to be used later)
    EPSILON: float = 0.2  # Exploration rate
    LEARNING_RATE: float = 0.01

settings = Settings()