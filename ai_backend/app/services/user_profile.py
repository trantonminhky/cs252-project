import numpy as np
from typing import Dict, List, Optional, Any

class UserProfile:
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.tag_preferences: Dict[str, float] = {}
        self.preference_vector: Optional[np.ndarray] = None
        self.alpha = 0.15  # Learning rate
        self.decay = 0.95  # Forgetting factor
    def update(self, item_tags: List[str], item_vector: np.ndarray, feedback_score: float):
        """
        Evolves the user profile based on a single interaction.
        """
        # --- A. Evolve Tag Weights ---
        if item_tags:
            for tag in item_tags:
                tag = str(tag).lower().strip()
                if not tag: continue

                current_weight = self.tag_preferences.get(tag, 0.0)
                # Formula: New = (Old * Decay) + (Learning * Feedback)
                new_weight = (current_weight * self.decay) + (self.alpha * feedback_score)
                self.tag_preferences[tag] = new_weight

        # --- B. Evolve Vector Space ---
        if self.preference_vector is None:
            self.preference_vector = item_vector
        else:
            # Move user vector closer to item vector
            direction = item_vector - self.preference_vector
            self.preference_vector += (self.alpha * feedback_score) * direction

    def get_top_tags(self, n=5) -> List[str]:
        """Returns the user's current top explicit interests."""
        sorted_tags = sorted(self.tag_preferences.items(), key=lambda x: x[1], reverse=True)
        return [t[0] for t in sorted_tags[:n]]

    def __str__(self):
        return f"{self.user_id}\nTags: {self.tag_preferences}"

    def to_dict(self) -> Dict[str, Any]:
        """Convert profile to a JSON-serializable dictionary."""
        return {
            "user_id": self.user_id,
            "tag_preferences": self.tag_preferences,
            # Numpy arrays are not JSON serializable, convert to list
            "preference_vector": self.preference_vector.tolist() if self.preference_vector is not None else None,
            "alpha": self.alpha,
            "decay": self.decay
        }
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'UserProfile':
        """Reconstruct a profile from a dictionary."""
        profile = cls(data.get("user_id", "unknown"))
        profile.tag_preferences = data.get("tag_preferences", {})

        vec_data = data.get("preference_vector")
        if vec_data:
            profile.preference_vector = np.array(vec_data)

        profile.alpha = data.get("alpha", 0.15)
        profile.decay = data.get("decay", 0.95)
        return profile