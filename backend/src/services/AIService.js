const axios = require('axios');
// const OpenAI = require('openai');
require('@heyputer/puter.js');
const config = require('../config/config');

// const client = new OpenAI({ apiKey: config.openAI.apiKey });

class AIService {
	constructor() {
		this.apiKey = config.openAI.apiKey;
		this.baseUrl = config.openAI.baseUrl || 'https://api.openai.com/v1';
	}

	// Send a prompt to the AI model and get a response


	async sendPrompt(prompt, model = 'gpt-5-nano') {
		if (!prompt) {
			throw new Error('Prompt is required');
		}

		try {
			puter.ai.chat(prompt, { model: model}).then(response => {
				puter.print(response);
			});
		} catch (err) {
			throw new Error(`Prompt failed: ${err.message}`);
		}
	}
}

module.exports = new AIService();