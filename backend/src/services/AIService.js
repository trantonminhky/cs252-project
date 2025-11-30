const config = require('../config/config').default;
const ServiceResponse = require('../helper/ServiceResponse');
const { Client } = require('@gradio/client')

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

	async extractTags(text) {
		if (!text) {
			const response = new ServiceResponse(
				false,
				400,
				"Text is required"
			);
			return response;
		}

		try {
			const client = await Client.connect("JustscrAPIng/cultour-filter-search");
			const result = await client.predict("/extract_tags", {
				user_text: text
			});
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				result
			);
			return response;
		} catch (err) {
			console.log(err);
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