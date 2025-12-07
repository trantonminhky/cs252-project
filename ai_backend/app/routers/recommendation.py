from fastapi import APIRouter, HTTPException
from typing import Dict, List, Any
from app.schemas import RecommendationRequest, UserFeedback
from app.services.recommender import ZeroShotRecommender
from app.services.user_profile import UserProfile

router = APIRouter()
rec_engine = ZeroShotRecommender()

@router.post("/recommend")
async def get_recommendations(request: RecommendationRequest):
    if request.profile_state:
        profile = UserProfile.from_dict(request.profile_state)
    else:
        profile = UserProfile(request.user_id)

    raw_results = rec_engine.recommend(profile, request.current_lat, request.current_lon, top_k=10)

    formatted_results = []
    for item in raw_results:
        formatted_results.append({
            "id": item.get("id"),
            "name": item.get("name"),
            "style": item.get("arch_style"),
            # Safety: Default to 0.0 if missing
            "score": round(item.get("match_score") or 0.0, 4),
            "distance_km": item.get("dist_km") or 0.0,
            "location": {
                "lat": item.get("lat"),
                "lon": item.get("lon")
            },
            "image": item.get("image_link"),
            "description": item.get("description"),
            "open_hours": item.get("open_hours")
        })

    return {
        "user_id": request.user_id,
        "top_interests": profile.get_top_tags(),
        "recommendations": formatted_results
    }

@router.post("/feedback")
async def record_feedback(feedback: UserFeedback):
    if feedback.profile_state:
        profile = UserProfile.from_dict(feedback.profile_state)
    else:
        profile = UserProfile(feedback.user_id)

    item_data, item_vector = rec_engine.get_item_by_id(feedback.item_id)

    if item_vector is None:
        raise HTTPException(status_code=404, detail=f"Item {feedback.item_id} not found")

    score_map = {"visit": 1.5, "like": 1.0, "click": 0.3, "view": 0.1, "dislike": -0.8}
    score = score_map.get(feedback.action.lower(), 0.1)

    tags = []
    if item_data.get('arch_style'):
        tags.extend([t.strip() for t in str(item_data['arch_style']).split(',') if t.strip()])
    if item_data.get('religion'):
        tags.extend([t.strip() for t in str(item_data['religion']).split(',') if t.strip()])
    if item_data.get('food_type'):
        tags.extend([t.strip() for t in str(item_data['food_type']).split(',') if t.strip()])

    profile.update(item_tags=tags, item_vector=item_vector, feedback_score=score)

    return {
        "status": "profile_updated",
        "current_vibe": profile.get_top_tags(),
        "profile_state": profile.to_dict()
    }