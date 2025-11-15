const axios = require('axios');
// const OpenAI = require('openai');
const config = require('../config/config');

let gemini;
import("gemini-ai").then(async ({ default: Gemini }) => {
	gemini = new Gemini(config.gemini.apiKey);
});

// const client = new OpenAI({ apiKey: config.openAI.apiKey });


class AIService {
	constructor() {
		this.apiKey = config.gemini.apiKey;
	}

	// Send a prompt to the AI model and get a response
	async sendPrompt(prompt, model = 'gemini-flash-latest') {
		if (!prompt) {
			throw new Error('Prompt is required');
		}

		try {
			const response = await gemini.ask(prompt, {model: model});
			console.log(response);
			return response;
		} catch (err) {
			throw new Error(`Prompt failed: ${err.message}`);
		}
	}
}

module.exports = new AIService();