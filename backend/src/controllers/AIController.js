import ServiceResponse from '../helper/ServiceResponse.js';
import AIService from '../services/AIService.js';

// TO-DO: DOCUMENT CONTROLLER CLASSES
class AIController {
	async sendPrompt(req, res, next) {
		try {
			const prompt = req.body.prompt;
			if (!prompt) {
				const response = new ServiceResponse(
					false,
					400,
					"Prompt parameter is required"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await AIService.sendPrompt(prompt);
			return void res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	async extractTags(req, res, next) {
		try {
			const text = req.query.text;
			if (!text) {
				const response = new ServiceResponse(
					false,
					400,
					"Text is required"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await AIService.extractTags(text);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async generateReviews(req, res, next) {
		try {
			const place = req.body.place;
			const response = await AIService.generateReviews(place);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new AIController();