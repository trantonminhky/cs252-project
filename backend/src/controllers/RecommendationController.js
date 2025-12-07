import RecommendationService from '../services/RecommendationService.js';
import ServiceResponse from '../helper/ServiceResponse.js';

class RecommendationController {
    async getRecommendations(req, res, next) {
        try {
            const { userID, lat, lon } = req.query;
            if (!userID || !lat || !lon) {
                const r = new ServiceResponse(false, 400, "Missing user ID, lat, or lon");
                return void res.status(r.statusCode).json(r.get());
            }
            const response = await RecommendationService.getRecommendations(userID, lat, lon);
            return void res.status(response.statusCode).json(response.get());
        } catch (error) {
            next(error);
        }
    }

    async sendFeedback(req, res, next) {
        try {
            const { userID, itemID, action } = req.body;
            if (!userID || !itemID || !action) {
                const response = new ServiceResponse(
					false,
					400,
					"Missing user ID, item ID, or action"
				);

                return void res.status(response.statusCode).json(response.get());
            }
			
            const response = await RecommendationService.sendFeedback(userID, itemID, action);
            return void res.status(response.statusCode).json(response.get());
        } catch (error) {
            next(error);
        }
    }
}

export default new RecommendationController();