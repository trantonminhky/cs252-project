from fastapi import APIRouter, HTTPException
from typing import Dict, List, Any
from app.schemas import RecommendationRequest, UserFeedback
from app.services.recommender import ZeroShotRecommender
from app.services.user_profile import UserProfile

router = APIRouter()

# Initialize the Recommender Logic
rec_engine = ZeroShotRecommender()

# NOTE: In-memory 'active_profiles' storage has been REMOVED.
# The system is now stateless. Node.js must send the profile state.

@router.post("/recommend")
async def get_recommendations(request: RecommendationRequest):
    """
    Returns a list of curated heritage sites for the user.
    """
    # 1. Reconstruct the profile from the request payload
    if request.profile_state:
        profile = UserProfile.from_dict(request.profile_state)
    else:
        # Cold Start: No history provided
        profile = UserProfile(request.user_id)

    # 2. Ask the engine for matches
    raw_results = rec_engine.recommend(profile, request.current_lat, request.current_lon, top_k=10)

    # 3. Format results
    formatted_results = []
    for item in raw_results:
        formatted_results.append({
            "id": item.get("item_id"),
            "name": item.get("name"),
            "style": item.get("arch_style"),
            "score": round(item.get("match_score", 0), 4),
            "location": {
                "lat": item.get("location.lat"),
                "lon": item.get("location.lon")
            },
            "image": item.get("image link")
        })

    return {
        "user_id": request.user_id,
        "top_interests": profile.get_top_tags(),
        "recommendations": formatted_results
    }

@router.post("/feedback")
async def record_feedback(feedback: UserFeedback):
    """
    The Evolution Step: Updates the user's vector based on what they did.
    Returns the NEW profile state to be saved by Node.js.
    """
    # 1. Reconstruct User Profile
    if feedback.profile_state:
        profile = UserProfile.from_dict(feedback.profile_state)
    else:
        profile = UserProfile(feedback.user_id)

    # 2. Get the item data
    item_data, item_vector = rec_engine.get_item_by_id(feedback.item_id)

    if item_vector is None:
        raise HTTPException(status_code=404, detail=f"Item {feedback.item_id} not found")

    # 3. Determine strength of feedback
    score_map = {
        "visit": 1.5,
        "like": 1.0,
        "click": 0.3,
        "view": 0.1,
        "dislike": -0.8
    }
    score = score_map.get(feedback.action.lower(), 0.1)

    tags = []
    if item_data.get('arch_style') and item_data['arch_style'] != 'unknown':
        tags.append(item_data['arch_style'])
    if item_data.get('religion') and item_data['religion'] != 'none':
        tags.append(item_data['religion'])

    # 5. Evolve the profile
    profile.update(item_tags=tags, item_vector=item_vector, feedback_score=score)

    # 6. RETURN THE UPDATED STATE
    # This JSON object must be saved into UserDB by the Node.js backend
    return {
        "status": "profile_updated",
        "current_vibe": profile.get_top_tags(),
        "profile_state": profile.to_dict()
    }