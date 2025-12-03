import config from '../config/config.js';
import ServiceResponse from '../helper/ServiceResponse.js';
import { Client } from '@gradio/client';
import Gemini from 'gemini-ai';
const gemini = new Gemini(config.gemini.APIKey);

class AIService {
	constructor() {
		this.apiKey = config.gemini.APIKey;
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
			const data = await gemini.ask(prompt, { model: model });
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
			const client = await Client.connect("JustscrAPIng/cultour-filter-search-en");
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
			console.error(err);
			const response = new ServiceResponse(
				false,
				500,
				"Something went wrong"
			);
			return response;
		}
	}

	async generateReviews(place, model = 'gemini-flash-latest') {
		if (!place) {
			const response = new ServiceResponse(
				false,
				400,
				"Place name is required"
			);
			return response;
		}

		try {
			const data = await gemini.ask(`Provide a list of reviews for the place with name ${place} in JSON format. The JSON object data should have these fields: { String username, String id, String content, int rating, String date (formatted according to flutter DateTime format)}. The response should be a JSON array of review objects. Do not put it in codeblock of triple backtick, I want raw data that is easily parse-able`, { model: model });
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				JSON.parse(data)
			)
			return response;
		} catch (err) {
			console.error(err);
			const response = new ServiceResponse(
				false,
				500,
				"Something went wrong"
			);
			return response;
		}
	}
}

export default new AIService();