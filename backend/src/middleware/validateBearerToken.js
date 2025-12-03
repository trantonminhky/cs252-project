import SessionTokensDB from "../db/SessionTokensDB.js";
import ServiceResponse from "../helper/ServiceResponse.js";

function validateBearerToken(req, res, next) {
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

export default validateBearerToken;