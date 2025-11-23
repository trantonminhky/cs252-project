const AIService = require('../services/AIService');

// TO-DO: DOCUMENT CONTROLLER CLASSES
class AIController {
	async ask(req, res, next) {
		try {
			const prompt = req.body.prompt;

			if (!prompt) {
				return res.status(400).json({
					success: false,
					error: { message: 'Prompt parameter is required' }
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