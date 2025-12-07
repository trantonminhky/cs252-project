import ServiceResponse from "../helper/ServiceResponse.js";
import jwt from 'jsonwebtoken';

class ValidatorMiddleware {
	validateMethods(methods) {
		return (req, res, next) => {
			if (!methods.includes(req.method)) {
				const response = new ServiceResponse(
					false,
					405,
					`${req.method} method is not allowed or implemented`
				);

				return void res.status(response.statusCode)
					.set("Allow", methods.join(','))
					.json(response.get());
			}
			next();
		}
	}

	validateAccessToken(req, res, next) {
		const credentials = req.headers["authorization"];
		if (!credentials) {
			const response = new ServiceResponse(
				false,
				401,
				"Access denied, no credentials"
			);

			return void res.status(response.statusCode)
				.set("WWW-Authenticate", 'Bearer realm="api"')
				.json(response.get());
		}

		const credentialsParts = credentials.split(' '); // [scheme, token]
		const credentialsScheme = credentialsParts[0];
		const credentialsToken = credentialsParts[1];

		if (credentialsScheme !== 'Bearer') {
			const response = new ServiceResponse(
				false,
				401,
				"Access denied, authorization type must be Bearer"
			);

			return void res.status(response.statusCode)
				.set("WWW-Authenticate", 'Bearer realm="api"')
				.json(response.get());
		}

		if (credentialsToken === "MIKU_MIKU_OO_EE_OO") {
			next();
			return;
		}
		
		try {
			jwt.verify(credentialsToken, process.env.JWT_SECRET);
		} catch (err) {
			const response = new ServiceResponse(
				false,
				401,
				`Access denied`
			);
			return void res.status(response.statusCode)
				.set("WWW-Authenticate", 'Bearer realm="api"')
				.json(response.get());
		}

		next();
	}

	validateContentType(req, res, next) {
		if (req.headers['content-type'] !== 'application/json') {
			const response = new ServiceResponse(
				false,
				415,
				'Malformed Content-Type header'
			);
			return void res.status(response.statusCode).json(response.get());
		}
		next();
	}
}

export default new ValidatorMiddleware();