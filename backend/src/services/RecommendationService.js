import axios from 'axios';
import ServiceResponse from '../helper/ServiceResponse.js';
import UserDB from '../db/UserDB.js';
import config from '../config/config.js';

class RecommendationService {
	constructor() {
		this.baseURL = config.pythonBackend.baseURL;
	}

	/**
	 * Fetch recommendations.
	 * Passes the existing profile state from Node.js -> Python.
	 */
	async getRecommendations(username, lat, lon) {
		// 1. Get existing profile state from DB (or null if new user)
		// 'rec_profile' is the specific key we use to store the AI data
		const profileState = UserDB.get(username, "preferenceVector") || null;

		// 2. Send to Python with the profile_state
		try {
			const axiosResponse = await axios.post(`${this.baseURL}/recommend`, {
				user_id: username,
				current_lat: parseFloat(lat),
				current_lon: parseFloat(lon),
				profile_state: profileState
			});
			return new ServiceResponse(
				true,
				200,
				"Success",
				axiosResponse.data
			);
		} catch (err) {
			const response = new ServiceResponse(
				false,
				502,
				"Something went wrong",
				err.toString()
			);
			return response;
		}
	}

	/**
	 * Send feedback (Like/Visit).
	 * Passes state Node.js -> Python -> Returns Updated State -> Node.js Saves it.
	 */
	async sendFeedback(username, itemId, action) {
		// 1. Get existing profile state
		const profileState = UserDB.get(username, "preferenceVector") || null;

		// 2. Send feedback + state to Python
		const axiosResponse = await axios.post(`${this.baseURL}/feedback`, {
			user_id: username,
			item_id: String(itemId),
			action: action,
			profile_state: profileState
		});

		// 3. IMPORTANT: Update UserDB with the new state returned by Python
		if (axiosResponse.data.profile_state) {
			UserDB.set(username, axiosResponse.data.profile_state, "preferenceVector");
			return new ServiceResponse(true, 200, "Feedback recorded & updated profile");
		}

		return new ServiceResponse(true, 200, "Feedback recorded");
	}
}
export default new RecommendationService();