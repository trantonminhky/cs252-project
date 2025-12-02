import pandas as pd
import numpy as np
import ast
import json
import logging
from pathlib import Path
import sys
import warnings

# Add project root to path
sys.path.append(str(Path(__file__).resolve().parents[1]))

from sentence_transformers import SentenceTransformer

# Configure Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
warnings.simplefilter(action='ignore', category=FutureWarning)

class DataPreprocessor:
    def __init__(self):
        self.base_dir = Path(__file__).resolve().parents[1]
        self.raw_data_path = self.base_dir / "data" / "raw" / "architecture.csv"
        self.processed_path = self.base_dir / "data" / "processed" / "item_embeddings.pkl"
        
        self.processed_path.parent.mkdir(parents=True, exist_ok=True)
        self.model_name = 'all-MiniLM-L6-v2'
        self.current_year = 2025
        self.df = None

    def load_data(self):
        logging.info(f"Loading data from {self.raw_data_path}...")
        if not self.raw_data_path.exists():
            raise FileNotFoundError(f"Input file not found: {self.raw_data_path}")
            
        self.df = pd.read_csv(self.raw_data_path)
        # Clean null strings
        self.df.replace(to_replace=[r'^none$', r'^None$', r'^\s*$'], value=np.nan, regex=True, inplace=True)

    def parse_identifiers(self):
        logging.info("Parsing OSM identifiers...")
        def safe_parse(val):
            try:
                parsed = ast.literal_eval(str(val))
                if isinstance(parsed, tuple) and len(parsed) >= 2:
                    return str(parsed[1]) # Return just the ID
            except (ValueError, SyntaxError):
                pass
            return str(val)

        self.df['item_id'] = self.df['id'].apply(safe_parse)

    def normalize_categories(self):
        logging.info("Normalizing categories...")
        
        # 1. Clean Architecture Style
        self.df['arch_style'] = self.df['arch_style'].astype(str).str.lower().str.strip().replace('nan', '')
        # Split "french, modernism" -> ['french', 'modernism']
        self.df['arch_style_tokens'] = self.df['arch_style'].str.split(r',\s*')
        
        # --- FIX: Use.str to access the first item of the list ---
        self.df['primary_style'] = self.df['arch_style_tokens'].str[0]
        
        # 2. Clean Religion
        if 'religion' in self.df.columns:
            self.df['religion'] = self.df['religion'].astype(str).str.lower().str.strip()
            self.df['religion'] = self.df['religion'].replace({'chinese': 'chinese_folk', 'nan': 'none'})

    def generate_embeddings(self):
        logging.info("Generating vector embeddings...")
        model = SentenceTransformer(self.model_name)
        
        # Create text soup
        self.df['content_soup'] = (
            "Style: " + self.df['arch_style'].fillna('') + ". " +
            "Type: " + self.df['building_type'].fillna('') + ". " +
            "Religion: " + self.df['religion'].fillna('') + ". " +
            "Description: " + self.df['description'].fillna('')
        )
        
        # Encode
        embeddings = model.encode(self.df['content_soup'].tolist(), batch_size=64, show_progress_bar=True)
        self.df['embedding'] = list(embeddings)

    def save_data(self):
        logging.info(f"Saving DataFrame to {self.processed_path}...")
        # CRITICAL: This ensures we save the DataFrame, not a list or array
        self.df.to_pickle(self.processed_path)
        logging.info("Done.")

    def run(self):
        self.load_data()
        self.parse_identifiers()
        self.normalize_categories()
        self.generate_embeddings()
        self.save_data()

if __name__ == "__main__":
    preprocessor = DataPreprocessor()
    preprocessor.run()