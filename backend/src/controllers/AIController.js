const ServiceResponse = require('../helper/ServiceResponse');
const AIService = require('../services/AIService');

// TO-DO: DOCUMENT CONTROLLER CLASSES
class AIController {
	async sendPrompt(req, res, next) {
		try {
			if (req.headers['content-type'] !== 'application/json') {
				const response = new ServiceResponse(
					false,
					415,
					'Malformed Content-Type header'
				);
				return res.status(response.statusCode).json(response.get());
			}

			const prompt = req.body.prompt;
			if (!prompt) {
				const response = new ServiceResponse(
					false,
					400,
					"Prompt parameter is required"
				);
				return res.status(response.statusCode).json(response.get());
			}

			const response = await AIService.sendPrompt(prompt);
			res.status(response.statusCode).json(response.get());
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
				return res.status(response.statusCode).json(response.get());
			}

			const response = await AIService.extractTags(text);
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

module.exports = new AIController();