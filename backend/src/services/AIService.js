import config from '../config/config.js';
import ServiceResponse from '../helper/ServiceResponse.js';
import { Client } from '@gradio/client';
import { GoogleGenAI } from '@google/genai';
const gemini = new GoogleGenAI(config.gemini.APIKey);

/**
 * AI service provider class.
 * @class
 */
class AIService {
	constructor() {
		this.tagsExtractionBaseURL = config.tagsExtraction
	}

	/**
	 * Service function for <b>/api/ai/send-prompt</b>. Sends prompt to Gemini with model. Supports <b>POST</b> requests.
	 * @param {String} prompt - Prompt to be fed into AI
	 * @param {String} [model='gemini-flash-latest'] - Gemini model
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl -X POST \
	 * --header 'Content-Type:application/json' \
	 * --data '{"prompt":"who is hatsune miku?"}' \
	 * http://localhost:3000/api/ai/send-prompt
	 * 
	 * @example <caption>Sample result</caption>
	 * 	{
     * 		"success": true,
     * 		"statusCode": 200,
     * 		"payload": {
     *    			"message": "Success (OK)",
     *    			"data": "Hatsune Miku is a fascinating and globally recognized..."
	 * 		}
	 * 	}
	 * 
	 * @property {OK} 200 - Successful request
 	 * @property {BAD_REQUEST} 400 - Missing prompt
	 * @property {CONTENT_TOO_LARGE} 413 - Prompt exceeds 500 characters
	 * @property {UNPROCESSABLE_ENTITY} 422 - The model name does not exist, or the model is internally broken
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
	 * @property {BAD_GATEWAY} 502 - Something went wrong with the upstream APIs (cooked)
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