const config = require('../config/config');
const ServiceResponse = require('../helper/ServiceResponse');

let gemini;
import("gemini-ai").then(async ({ default: Gemini }) => {
	gemini = new Gemini(config.gemini.apiKey);
});


class AIService {
	constructor() {
		this.apiKey = config.gemini.apiKey;
	}

	/**
	 * Sends prompt to Gemini with model.
	 * @param {String} prompt - Input prompt
	 * @param {String} [model='gemini-flash-latest'] - Gemini model
	 * @returns {Promise<ServiceResponse>}
	 */
	async sendPrompt(prompt, model = 'gemini-flash-latest') {
		if (!prompt) {
			const response = new ServiceResponse(
				false,
				400,
				'Prompt is required'
			);
			return response;
		}

		try {
			const data = await gemini.ask(prompt, {model: model});
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				data
			)
			return response;
		} catch (err) {
			const response = new ServiceResponse(
				false,
				500,
				"Something went wrong"
			);
			return response;
		}
	}
}

module.exports = new AIService();