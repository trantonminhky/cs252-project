const AIService = require('../services/ai/aiService');

class AIController {
	async ask(req, res, next) {
		try {
			const { prompt } = req.query;

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