import ServiceResponse from '../helper/ServiceResponse.js';
import AIService from '../services/AIService.js';

// TO-DO: DOCUMENT CONTROLLER CLASSES
class AIController {
	async sendPrompt(req, res, next) {
		try {
			const bearerCredentials = req.headers["authorization"];

			if (!bearerCredentials) {
				const response = new ServiceResponse(
					false,
					401,
					"Access denied, no credentials"
				);

				return (res
					.status(response.statusCode)
					.set("WWW-Authenticate", 'Bearer realm="api"')
					.json(response.get())
				);
			}

			const credentials = bearerCredentials.split(' '); // [scheme, token]
			if (credentials[0] !== 'Bearer') {
				const response = new ServiceResponse(
					false,
					401,
					"Access denied, authorization type must be Bearer"
				);

				return (res
					.status(response.statusCode)
					.set("WWW-Authenticate", 'Bearer realm="api"')
					.json(response.get())
				);
			}

			if (req.headers['content-type'] !== 'application/json') {
				const response = new ServiceResponse(
					false,
					415,
					'Malformed Content-Type header'
				);
				return res.status(response.statusCode).json(response.get());
			}

			const prompt = req.body.prompt;
			if (!prompt) {
				const response = new ServiceResponse(
					false,
					400,
					"Prompt parameter is required"
				);
				return res.status(response.statusCode).json(response.get());
			}

			const response = await AIService.sendPrompt(prompt);
			res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	async extractTags(req, res, next) {
		try {
			const text = req.query.text;
			if (!text) {
				const response = new ServiceResponse(
					false,
					400,
					"Text is required"
				);
				return res.status(response.statusCode).json(response.get());
			}

			const response = await AIService.extractTags(text);
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async generateReviews(req, res, next) {
		try {
			const place = req.body.place;
			const response = await AIService.generateReviews(place);
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new AIController();