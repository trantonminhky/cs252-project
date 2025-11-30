from pydantic import BaseModel
from typing import List, Optional

class Location(BaseModel):
    lat: float
    lon: float

# Represents a row from your CSV 
class HeritageSite(BaseModel):
    id: str
    name: str
    location: Location
    building_type: Optional[str] = None
    arch_style: Optional[str] = None
    age: Optional[str] = None
    religion: Optional[str] = None
    image_link: Optional[str] = None
    description: Optional[str] = None
    tags: Optional[List[str]] = None

# Input for the recommendation endpoint
class RecommendationRequest(BaseModel):
    user_id: str
    current_lat: float
    current_lon: float
    context: Optional[str] = "general" # e.g., "morning", "exploration"

# Input for updating the RL agent
class UserFeedback(BaseModel):
    user_id: str
    item_id: str
    action: str  # e.g., "click", "visit", "ignore"
    dwell_time: Optional[float] = 0.0
    profile_state: Optional[Dict[str, Any]] = None