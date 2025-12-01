import pandas as pd
import numpy as np
from pathlib import Path
from sklearn.metrics.pairwise import cosine_similarity
from app.services.user_profile import UserProfile

class ZeroShotRecommender:
    def __init__(self):
        # Path to the pickle file we created
        self.data_path = Path(__file__).resolve().parents[2] / "data" / "processed" / "item_embeddings.pkl"
        self.df = None
        self.item_matrix = None
        self._load_data()

    def _load_data(self):
        if not self.data_path.exists():
            raise FileNotFoundError(f"Processed data not found at {self.data_path}. Run preprocess_data.py first.")
        
        # Load the pickle
        self.df = pd.read_pickle(self.data_path)
        self.df['embedding'] = self.df['embedding'].apply(lambda e: np.array(e).reshape(-1))
        print(self.df["embedding"].apply(lambda x: np.array(x).shape).value_counts())

        # Convert the 'embedding' column (list of floats) into a 2D Numpy Matrix
        # This makes math blazing fast
        self.item_matrix = np.vstack(self.df['embedding'].values)
        print(f"Loaded {len(self.df)} locations with embeddings.")

    def recommend(self, user_profile: UserProfile, current_lat: float, current_lon: float, top_k=10):
        """
        Hybrid Recommendation: Vector Similarity + Tag Matching + Location Proximity
        """
        # --- 1. COLD START ---
        # If no profile, fallback to "What is popular AND nearby"
        if user_profile.preference_vector is None:
            # In production, you would likely filter this sample by distance 
            return self.df.sample(top_k).to_dict(orient='records')

        # --- 2. SEMANTIC SCORE (0.0 to 1.0) ---
        user_vec = user_profile.preference_vector.reshape(1, -1)
        
        # Ensure inputs are clean before math (handle NaNs)
        user_vec = np.nan_to_num(user_vec, nan=0.0)
        clean_matrix = np.nan_to_num(self.item_matrix, nan=0.0)

        # Cosine Similarity calculates (A . B) / (|A| * |B|)
        # This function handles the normalization internally, so we don't 
        # need to manually divide by norms and corrupt the original matrix.
        semantic_scores = cosine_similarity(user_vec, clean_matrix).flatten()

        # --- 3. TAG BOOST SCORE (0.0 or 0.15) ---
        tag_boost = np.zeros(len(self.df))
        top_tags = user_profile.get_top_tags(3)
        if top_tags:
            # Create a regex pattern from the tags (e.g., "Gothic|Christian")
            pattern = '|'.join([t for t in top_tags if t])
            if pattern:
                matches = self.df['content_soup'].str.contains(pattern, case=False, na=False)
                tag_boost[matches] = 0.15

        # --- 4. LOCATION SCORE (0.0 to 1.0) ---
        # Calculate distance in km using Vectorized Haversine formula
        distances_km = self._haversine_vectorized(
            current_lat, current_lon, 
            self.df['location.lat'].values, 
            self.df['location.lon'].values
        )
        distances_km = np.nan_to_num(distances_km, nan=0.0)

        # Apply "Inverse Distance Decay": 1 / (1 + distance)
        # 0km -> 1.0, 1km -> 0.5, 10km -> 0.09
        location_scores = 1 / (1 + distances_km)

        # --- 5. FINAL WEIGHTED SUM ---
        # We weigh Semantic preferences higher (0.6) than Location (0.3) 
        # so we don't just recommend boring stuff because it's close.
        w_semantic = 0.6
        w_location = 0.3
        w_tags     = 0.1
        
        final_scores = (w_semantic * semantic_scores) + \
                       (w_location * location_scores) + \
                       (w_tags * tag_boost)
        
        # Clean final scores to prevent JSON serialization errors
        final_scores = np.nan_to_num(final_scores, nan=0.0, posinf=1e9, neginf=-1e9)

        # --- 6. RANKING ---
        # Get indices of the top K highest scores
        top_indices = final_scores.argsort()[-top_k:][::-1]
        
        # Construct result set
        results = self.df.iloc[top_indices].copy()
        results['match_score'] = final_scores[top_indices]
        results['dist_km'] = distances_km[top_indices].round(2)
        
        # Replace NaN with None for valid JSON output
        results = results.replace({np.nan: None})
        
        return results.drop(columns=['embedding']).to_dict(orient='records')

    def _haversine_vectorized(self, lat1, lon1, lat2_array, lon2_array):
        """
        Calculate distance between one point (user) and many points (items) efficiently.
        Returns array of distances in kilometers.
        """
        R = 6371.0 # Earth radius in km
        
        dlat = np.radians(lat2_array - lat1)
        dlon = np.radians(lon2_array - lon1)
        
        a = np.sin(dlat / 2)**2 + \
            np.cos(np.radians(lat1)) * np.cos(np.radians(lat2_array)) * \
            np.sin(dlon / 2)**2
        
        a = np.clip(a, 0.0, 1.0)
        c = 2 * np.arctan2(np.sqrt(a), np.sqrt(1 - a))
        return R * c

    def get_item_by_id(self, item_id: str):
        """Helper to find an item's data and vector by its ID"""
        row = self.df[self.df['item_id'] == str(item_id)]
        if row.empty:
            return None, None
        return row.iloc[0].to_dict(), row.iloc[0]['embedding']