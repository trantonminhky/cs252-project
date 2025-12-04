import ServiceResponse from "../helper/ServiceResponse.js";

class ValidatorMiddleware {
	validateSessionToken(req, res, next) {
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

		// if the credentials are invalid
		let authorizationStatus = SessionTokensDB.check(credentialsToken);
		if (authorizationStatus !== "valid") {
			const response = new ServiceResponse(
				false,
				401,
				`Access denied, ${authorizationStatus}`
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