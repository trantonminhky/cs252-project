from pydantic import BaseModel
from typing import List, Optional, Dict, Any, Union

class Location(BaseModel):
    lat: float
    lon: float

class HeritageSite(BaseModel):
    id: Union[int, str]
    name: str
    location: Location
    image_link: Optional[str] = None
    description: Optional[str] = None

class RecommendationRequest(BaseModel):
    user_id: str
    current_lat: float
    current_lon: float
    profile_state: Optional[Dict[str, Any]] = None

class UserFeedback(BaseModel):
    user_id: str
    # FIX: Allows integer ID (119) or string ID ("119")
    item_id: Union[int, str]
    action: str 
    profile_state: Optional[Dict[str, Any]] = None