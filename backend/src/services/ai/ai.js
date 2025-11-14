const axios = require('axios');
const OpenAI = require('openai');
const config = require('../../config/config');

const client = new OpenAI({ apiKey: config.openai.apiKey });

class AIService {
	constructor() {
		this.apiKey = config.openai.apiKey;
		this.baseUrl = config.openai.baseUrl || 'https://api.openai.com/v1';
	}

	// Send a prompt to the AI model and get a response


	async sendPrompt(prompt, model = 'gpt-4') {
		if (!prompt) {
			throw new Error('Prompt is required');
		}
