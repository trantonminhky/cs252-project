import SessionTokensDB from "../db/SessionTokensDB.js";
import ServiceResponse from "./ServiceResponse.js";

function validateBearerToken(credentials, res) {
	if (!credentials) {
		const response = new ServiceResponse(
			false,
			401,
			"Access denied, no credentials"
		);

		res.status(response.statusCode)
			.set("WWW-Authenticate", 'Bearer realm="api"')
			.json(response.get());
		return false;
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

		res.status(response.statusCode)
			.set("WWW-Authenticate", 'Bearer realm="api"')
			.json(response.get());
		return false;
	}

	// if the credentials are invalid
	let authorizationStatus = SessionTokensDB.check(credentialsToken);
	if (authorizationStatus !== "valid") {
		const response = new ServiceResponse(
			false,
			401,
			`Access denied, ${authorizationStatus}`
		);

		res.status(response.statusCode)
			.set("WWW-Authenticate", 'Bearer realm="api"')
			.json(response.get());
		return false;
	}

	return true;
}

export default validateBearerToken;