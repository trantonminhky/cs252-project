import RecommendationService from '../services/RecommendationService.js';
import ServiceResponse from '../helper/ServiceResponse.js';

class RecommendationController {
    async getRecommendations(req, res, next) {
        try {
            const { username, lat, lon } = req.query;
            if (!username || !lat || !lon) {
                const r = new ServiceResponse(false, 400, "Missing username, lat, or lon");
                return void res.status(r.statusCode).json(r.get());
            }
            const response = await RecommendationService.getRecommendations(username, lat, lon);
            return void res.status(response.statusCode).json(response.get());
        } catch (error) {
            next(error);
        }
    }

    async sendFeedback(req, res, next) {
        try {
            const { username, itemId, action } = req.body;
            if (!username || !itemId || !action) {
                const response = new ServiceResponse(
					false,
					400,
					"Missing username, itemId, or action"
				);

                return void res.status(response.statusCode).json(response.get());
            }
			
            const response = await RecommendationService.sendFeedback(username, itemId, action);
            return void res.status(response.statusCode).json(response.get());
        } catch (error) {
            next(error);
        }
    }
}

export default new RecommendationController();