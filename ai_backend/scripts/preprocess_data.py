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
        self.raw_data_path = self.base_dir / "data" / "raw" / "transformed_data_en_fixed.json"
        self.processed_path = self.base_dir / "data" / "processed" / "item_embeddings.pkl"
        
        self.processed_path.parent.mkdir(parents=True, exist_ok=True)
        self.model_name = 'all-MiniLM-L6-v2'
        self.df = None

    def load_data(self):
        logging.info(f"Loading data from {self.raw_data_path}...")
        if not self.raw_data_path.exists():
            raise FileNotFoundError(f"Input file not found: {self.raw_data_path}")
            
        with open(self.raw_data_path, 'r', encoding='utf-8') as f:
            dataf = json.load(f)
        
        self.df = pd.DataFrame(dataf)
        logging.info(f"Loaded {len(self.df)} records.")

    def parse_identifiers(self):
        logging.info("Formatting identifiers...")
        self.df['item_id'] = self.df['id'].astype(str)

    def process_attributes(self):
        logging.info("Unpacking tags and attributes...")

        # 1. Helper to extract tags safely
        def extract_tag_value(tags_dict, key):
            if not isinstance(tags_dict, dict):
                return None
            
            value_list = tags_dict.get(key, [])
            if isinstance(value_list, list) and len(value_list) > 0:
                return ", ".join([str(v) for v in value_list if v])
            return None

        # 2. Helper to format open hours (handles multiple ranges)
        def format_hours(hours_val):
            # Expecting list like ["0800", "1115", "1400", "1700"]
            if not isinstance(hours_val, list) or not hours_val:
                return None
            
            # Clean and ensure strings
            valid_hours = [str(h) for h in hours_val if h]
            
            ranges = []
            # Iterate in steps of 2 to get pairs (start, end)
            for i in range(0, len(valid_hours) - 1, 2):
                start = valid_hours[i]
                end = valid_hours[i+1]
                
                # Format 0800 -> 08:00 if needed
                if len(start) == 4 and ":" not in start: start = f"{start[:2]}:{start[2:]}"
                if len(end) == 4 and ":" not in end: end = f"{end[:2]}:{end[2:]}"
                
                ranges.append(f"{start} to {end}")
            
            if ranges:
                # Join multiple ranges with ", "
                # e.g., "08:00 to 11:15, 14:00 to 17:00"
                return ", ".join(ranges)
            return None

        # Apply extractions
        self.df['arch_style'] = self.df['tags'].apply(lambda x: extract_tag_value(x, 'archStyle'))
        self.df['building_type'] = self.df['tags'].apply(lambda x: extract_tag_value(x, 'buildingType'))
        self.df['religion'] = self.df['tags'].apply(lambda x: extract_tag_value(x, 'religion'))
        self.df['food_type'] = self.df['tags'].apply(lambda x: extract_tag_value(x, 'foodType'))
        
        # Apply hours formatting
        self.df['hours_str'] = self.df['open_hours'].apply(format_hours)
        
        # Normalize simple text fields
        self.df['day_off'] = self.df['day_off'].astype(str).replace({'None': None, 'nan': None})

        # Lowercase text columns for consistency
        cols_to_clean = ['arch_style', 'building_type', 'religion', 'food_type', 'day_off']
        for col in cols_to_clean:
            if col in self.df.columns:
                self.df[col] = self.df[col].str.lower().str.strip()

    def generate_embeddings(self):
        logging.info("Generating vector embeddings...")
        model = SentenceTransformer(self.model_name)
        
        def create_soup(row):
            parts = []
            
            if row.get('name'): parts.append(f"Name: {row['name']}")
            if row.get('building_type'): parts.append(f"Type: {row['building_type']}")
            if row.get('food_type'): parts.append(f"Cuisine: {row['food_type']}")
            if row.get('arch_style'): parts.append(f"Style: {row['arch_style']}")
            if row.get('religion'): parts.append(f"Religion: {row['religion']}")
            
            # Added Day Off
            if row.get('day_off'): parts.append(f"Day Off: {row['day_off']}")
            
            # Hours will now look like "Open Hours: 08:00 to 11:15, 14:00 to 17:00"
            if row.get('hours_str'): parts.append(f"Open Hours: {row['hours_str']}")
                
            if row.get('description'): 
                desc = str(row['description']).replace('\n', ' ')
                parts.append(f"Description: {desc}")
                
            return ". ".join(parts)

        # Apply the soup function row by row
        self.df['content_soup'] = self.df.apply(create_soup, axis=1)
        
        logging.info(f"Example content soup: {self.df['content_soup'].iloc[0]}")
        
        # Encode
        embeddings = model.encode(self.df['content_soup'].tolist(), batch_size=64, show_progress_bar=True)
        self.df['embedding'] = list(embeddings)

    def save_data(self):
        logging.info(f"Saving DataFrame to {self.processed_path}...")
        self.df.to_pickle(self.processed_path)
        logging.info("Done.")

    def run(self):
        self.load_data()
        self.parse_identifiers()
        self.process_attributes()
        self.generate_embeddings()
        self.save_data()

if __name__ == "__main__":
    preprocessor = DataPreprocessor()
    preprocessor.run()