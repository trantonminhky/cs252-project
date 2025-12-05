import config from '../config/config.js';
import ServiceResponse from '../helper/ServiceResponse.js';
import { Client } from '@gradio/client';
import { GoogleGenAI } from '@google/genai';
const gemini = new GoogleGenAI(config.gemini.APIKey);

class AIService {
	constructor() {
		this.tagsExtractionBaseURL = config.tagsExtraction
	}

	/**
	 * Sends prompt to Gemini with model.
	 * @param {String} prompt - Input prompt
	 * @param {String} [model='gemini-flash-latest'] - Gemini model
	 * @returns {Promise<ServiceResponse>}
	 */
	async sendPrompt(prompt, model = 'gemini-flash-latest') {
		try {
			await gemini.models.get({ model: model });
		} catch (err) {
			const response = new ServiceResponse(
				false,
				422,
				"Cannot load model",
				err.toString()
			);
			return response;
		}

		try {
			const data = await gemini.models.generateContent({
				model: model,
				contents: prompt
			});
			const text = data.candidates[0].content.parts[0].text;
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				text
			);
			return response;
		} catch (err) {
			const response = new ServiceResponse(
				false,
				502,
				"Something went wrong",
				err.toString()
			);
			return response;
		}
	}

	async extractTags(text) {
		try {
			const client = await Client.connect(this.tagsExtractionBaseURL);
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
			const response = new ServiceResponse(
				false,
				502,
				"Something went wrong",
				err.toString()
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
			await gemini.models.get({ model: model });
		} catch (err) {
			const response = new ServiceResponse(
				false,
				422,
				"Cannot load model",
				err.toString()
			);
			return response;
		}

		try {
			const data = await gemini.models.generateContent({
				model: model,
				contents: `Provide a list of reviews for the place with name ${place} in JSON format. The JSON object data should have these fields: { String username, String id, String content, int rating, String date (formatted according to flutter DateTime format)}. The response should be a JSON array of review objects. Do not put it in codeblock of triple backtick, I want raw data that is easily parse-able`
			});
			const text = data.candidates[0].content.parts[0].text;
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				JSON.parse(text)
			)
			return response;
		} catch (err) {
			const response = new ServiceResponse(
				false,
				502,
				"Something went wrong",
				err.toString()
			);
			return response;
		}
	}
}

export default new AIService();