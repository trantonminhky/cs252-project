import pandas as pd
import numpy as np
from pathlib import Path
from sklearn.metrics.pairwise import cosine_similarity
from app.services.user_profile import UserProfile

class ZeroShotRecommender:
    def __init__(self):
        self.data_path = Path(__file__).resolve().parents[2] / "data" / "processed" / "item_embeddings.pkl"
        self.df = None
        self.item_matrix = None
        self._load_data()

    def _load_data(self):
        if not self.data_path.exists():
            raise FileNotFoundError(f"Processed data not found at {self.data_path}. Run preprocess_data.py first.")
        
        self.df = pd.read_pickle(self.data_path)
        
        # Robust handling of coordinates
        if 'lat' in self.df.columns:
            self.df['lat'] = pd.to_numeric(self.df['lat'], errors='coerce').fillna(0.0)
            self.df['lon'] = pd.to_numeric(self.df['lon'], errors='coerce').fillna(0.0)
        
        self.df['embedding'] = self.df['embedding'].apply(lambda e: np.array(e).reshape(-1))
        self.item_matrix = np.vstack(self.df['embedding'].values)
        print(f"Loaded {len(self.df)} items.")

    def recommend(self, user_profile: UserProfile, current_lat: float, current_lon: float, top_k=10):
        # --- 1. PRE-CALCULATE DISTANCE (For both Cold and Warm start) ---
        distances_km = self._haversine_vectorized(
            current_lat, current_lon, 
            self.df['lat'].values, 
            self.df['lon'].values
        )
        # Handle NaNs if any lat/lon was invalid
        distances_km = np.nan_to_num(distances_km, nan=9999.0)

        # --- 2. COLD START (No User History) ---
        
        if user_profile.preference_vector is None:
            # Create a working copy to attach temporary columns
            cold_df = self.df.copy()
            cold_df['dist_km'] = distances_km.round(2)
            cold_df['match_score'] = 0.0  # Default score for cold items
        
            # --- Sort by distance instead of random sampling ---
            cold_df = cold_df.sort_values('dist_km', ascending=True)
        
            # Take closest top_k items
            sample = cold_df.head(top_k)
        
            # Clean up NaNs before returning
            sample = sample.replace({np.nan: None})
        
            return sample.drop(columns=['embedding']).to_dict(orient='records')


        # --- 3. WARM START (User has history) ---
        
        # A. Semantic Score
        user_vec = user_profile.preference_vector.reshape(1, -1)
        user_vec = np.nan_to_num(user_vec, nan=0.0)
        clean_matrix = np.nan_to_num(self.item_matrix, nan=0.0)
        semantic_scores = cosine_similarity(user_vec, clean_matrix).flatten()

        # B. Tag Boost
        tag_boost = np.zeros(len(self.df))
        top_tags = user_profile.get_top_tags(3)
        if top_tags:
            pattern = '|'.join([t for t in top_tags if t])
            if pattern:
                matches = self.df['content_soup'].str.contains(pattern, case=False, na=False)
                tag_boost[matches] = 0.15

        # C. Location Score (Inverse Distance)
        # Avoid division by zero
        location_scores = 1 / (1 + distances_km)

        # D. Weighted Sum
        w_semantic, w_location, w_tags = 0.6, 0.3, 0.1
        final_scores = (w_semantic * semantic_scores) + (w_location * location_scores) + (w_tags * tag_boost)
        final_scores = np.nan_to_num(final_scores, nan=0.0, posinf=0.0, neginf=0.0)

        # E. Ranking
        top_indices = final_scores.argsort()[-top_k:][::-1]
        
        # F. Construct Result
        results = self.df.iloc[top_indices].copy()
        results['match_score'] = final_scores[top_indices]
        results['dist_km'] = distances_km[top_indices].round(2)
        
        results = results.replace({np.nan: None})
        return results.drop(columns=['embedding']).to_dict(orient='records')

    def _haversine_vectorized(self, lat1, lon1, lat2_array, lon2_array):
        R = 6371.0 
        dlat = np.radians(lat2_array - lat1)
        dlon = np.radians(lon2_array - lon1)
        a = np.sin(dlat / 2)**2 + np.cos(np.radians(lat1)) * np.cos(np.radians(lat2_array)) * np.sin(dlon / 2)**2
        a = np.clip(a, 0.0, 1.0)
        c = 2 * np.arctan2(np.sqrt(a), np.sqrt(1 - a))
        return R * c

    def get_item_by_id(self, item_id):
        try:
            int_id = int(item_id)
            row = self.df[self.df['id'] == int_id]
            if not row.empty:
                return row.iloc[0].to_dict(), row.iloc[0]['embedding']
        except ValueError:
            pass
        return None, None