const config = require('../config/config');
const ServiceResponse = require('../helper/ServiceResponse');

// THESE SERVICES ARE SOMEWHAT OUTDATED
// TO-DO: DEAL WITH THESE FUCKERS

let gemini;
import("gemini-ai").then(async ({ default: Gemini }) => {
	gemini = new Gemini(config.gemini.apiKey);
});


class AIService {
	constructor() {
		this.apiKey = config.gemini.apiKey;
	}

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