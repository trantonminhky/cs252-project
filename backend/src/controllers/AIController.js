import ServiceResponse from '../helper/ServiceResponse.js';
import AIService from '../services/AIService.js';

const PROMPT_MAXIMUM_LENGTH = 500;

/**
 * Controllers for /api/ai/ endpoints family.
 * @class
 */
class AIController {
	/**
	 * Controller for <b>/api/ai/send-prompt</b>. Supports <b>POST</b> requests.
	 * @param {String} prompt - The prompt to be fed to AI
	 * @param {String} [model] - Gemini model. By default the model is gemini-flash-latest
	 * @returns {ServiceResponse}
	 * 
	 * @example
	 * curl -X POST \
	 * --header 'Content-Type:application/json' \
	 * --data '{"prompt":"who is hatsune miku?"}' \
	 * http://localhost:3000
	 */
	async sendPrompt(req, res, next) {
		try {
			const prompt = req.body.prompt;
			const model = req.body.model;

			if (!prompt) {
				const response = new ServiceResponse(
					false,
					400,
					"Prompt parameter is required"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			if (prompt.length > PROMPT_MAXIMUM_LENGTH) {
				const response = new ServiceResponse(
					false,
					413,
					"Prompt must not exceed 500 characters"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await AIService.sendPrompt(prompt, model);
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
			const model = req.body.model;

			if (!place) {
				const response = new ServiceResponse(
					false,
					400,
					"Place name is required"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await AIService.generateReviews(place, model);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new AIController();