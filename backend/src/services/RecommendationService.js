import axios from 'axios';
import ServiceResponse from '../helper/ServiceResponse.js';
import UserDB from '../db/UserDB.js';

const PYTHON_API_URL = 'https://committee-academy-rolls-club.trycloudflare.com/api/v1';

class RecommendationService {

	/**
	 * Fetch recommendations.
	 * Passes the existing profile state from Node.js -> Python.
	 */
	async getRecommendations(username, lat, lon) {
		try {
			// 1. Get existing profile state from DB (or null if new user)
			// 'rec_profile' is the specific key we use to store the AI data
			const profileState = UserDB.get(username, "rec_profile") || null;

			// 2. Send to Python with the profile_state
			const response = await axios.post(`${PYTHON_API_URL}/recommend`, {
				user_id: username,
				current_lat: parseFloat(lat),
				current_lon: parseFloat(lon),
				profile_state: profileState
			});
			return new ServiceResponse(true, 200, "Success", response.data);
		} catch (error) {
			console.error("Rec Engine Error:", error.message);
			// Return empty list so the app doesn't crash if Python is offline
			return new ServiceResponse(false, 500, "Engine offline", { recommendations: [] });
		}
	}

	/**
	 * Send feedback (Like/Visit).
	 * Passes state Node.js -> Python -> Returns Updated State -> Node.js Saves it.
	 */
	async sendFeedback(username, itemId, action) {
		try {
			// 1. Get existing profile state
			const profileState = UserDB.get(username, "rec_profile") || null;

			// 2. Send feedback + state to Python
			const response = await axios.post(`${PYTHON_API_URL}/feedback`, {
				user_id: username,
				item_id: String(itemId),
				action: action,
				profile_state: profileState
			});

			// 3. IMPORTANT: Update UserDB with the new state returned by Python
			if (response.data.profile_state) {
				UserDB.set(username, response.data.profile_state, "rec_profile");
				return new ServiceResponse(true, 200, "Feedback recorded & updated profile");
			}

            // 3. IMPORTANT: Update UserDB with the new state returned by Python
            if (response.data.profile_state) {
                UserDB.set(username, response.data.profile_state, "rec_profile");
				return new ServiceResponse(true, 200, "Feedback recorded & updated profile");
            }

            return new ServiceResponse(true, 200, "Feedback recorded");
        } catch (error) {
            console.error("Feedback Error:", error.message);
            // We return success to the UI even if the stats engine fails
            return new ServiceResponse(true, 200, "Feedback skipped (Engine offline)");
        }
    }
}
export default new RecommendationService();