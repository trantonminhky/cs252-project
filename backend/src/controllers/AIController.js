const ServiceResponse = require('../helper/ServiceResponse');
const AIService = require('../services/AIService');

// TO-DO: DOCUMENT CONTROLLER CLASSES
class AIController {
	async ask(req, res, next) {
		try {
			if (req.headers['content-type'] !== 'application/json') {
				const response = new ServiceResponse(
					false,
					415,
					'Malformed Content-Type header'
				)
				return res.status(response.statusCode).json(response.get());
			}

			const prompt = req.body.prompt;
			if (!prompt) {
				return res.status(400).json({
					success: false,
					payload: { message: 'Prompt parameter is required' }
				});
			}

			const result = await AIService.sendPrompt(prompt);

			res.json({
				success: true,
				data: result
			});
		} catch (error) {
			next(error);
		}
	}
}

module.exports = new AIController();