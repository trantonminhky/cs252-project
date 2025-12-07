import pandas as pd
import numpy as np
import json
import logging
from pathlib import Path
import sys
import warnings

# --- CRITICAL IMPORT ---
from sentence_transformers import SentenceTransformer
# -----------------------

# Add project root to path
sys.path.append(str(Path(__file__).resolve().parents[1]))

# Configure Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
warnings.simplefilter(action='ignore', category=FutureWarning)

class DataPreprocessor:
    def __init__(self):
        self.base_dir = Path(__file__).resolve().parents[1]
        self.new_json_path = self.base_dir / "data" / "raw" / "transformed_data_en_fixed.json"
        self.processed_path = self.base_dir / "data" / "processed" / "item_embeddings.pkl"
        
        self.processed_path.parent.mkdir(parents=True, exist_ok=True)
        self.model_name = 'all-MiniLM-L6-v2'
        self.df = None

    def load_data(self):
        logging.info("Loading new JSON data...")
        if not self.new_json_path.exists():
            raise FileNotFoundError(f"Input file not found: {self.new_json_path}")
            
        with open(self.new_json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        self.df = pd.DataFrame(data)
        logging.info(f"Loaded {len(self.df)} items from JSON.")

    def normalize_features(self):
        logging.info("Normalizing features...")

        # 1. Clean Lat/Lon to prevent 'null' distances later
        # Coerce to numeric, turn errors to NaN, then fill with 0.0
        self.df['lat'] = pd.to_numeric(self.df['lat'], errors='coerce').fillna(0.0)
        self.df['lon'] = pd.to_numeric(self.df['lon'], errors='coerce').fillna(0.0)

        # 2. Flatten tags
        def extract_tag(row, category):
            tags_dict = row.get('tags', {})
            if isinstance(tags_dict, dict):
                vals = tags_dict.get(category, [])
                if isinstance(vals, list):
                    return ', '.join(vals)
            return ''

        self.df['arch_style'] = self.df.apply(lambda x: extract_tag(x, 'archStyle'), axis=1)
        self.df['religion'] = self.df.apply(lambda x: extract_tag(x, 'religion'), axis=1)
        self.df['building_type'] = self.df.apply(lambda x: extract_tag(x, 'buildingType'), axis=1)
        self.df['food_type'] = self.df.apply(lambda x: extract_tag(x, 'foodType'), axis=1)

        # 3. Fill text
        self.df['description'] = self.df['description'].fillna('')
        self.df['name'] = self.df['name'].fillna('Unknown')

    def generate_embeddings(self):
        logging.info("Generating vector embeddings...")
        model = SentenceTransformer(self.model_name)
        
        self.df['content_soup'] = (
            "Name: " + self.df['name'] + ". " +
            "Style: " + self.df['arch_style'] + ". " +
            "Type: " + self.df['building_type'] + ". " +
            "Religion: " + self.df['religion'] + ". " +
            "Food: " + self.df['food_type'] + ". " +
            "Description: " + self.df['description']
        )
        
        embeddings = model.encode(self.df['content_soup'].tolist(), batch_size=64, show_progress_bar=True)
        self.df['embedding'] = list(embeddings)

    def save_data(self):
        logging.info(f"Saving processed data to {self.processed_path}...")
        self.df.to_pickle(self.processed_path)
        logging.info("Done.")

    def run(self):
        self.load_data()
        self.normalize_features()
        self.generate_embeddings()
        self.save_data()

if __name__ == "__main__":
    preprocessor = DataPreprocessor()
    preprocessor.run()