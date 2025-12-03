import SessionTokensDB from "../db/SessionTokensDB";
import ServiceResponse from "./ServiceResponse";

function validateBearerToken(credentials, res) {
	if (!credentials) {
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

	const credentialsParts = credentials.split(' '); // [scheme, token]
	const credentialsScheme = credentialsParts[0];
	const credentialsToken = credentialsParts[1];

	if (credentialsScheme !== 'Bearer') {
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

	// if the credentials are invalid
	let authorizationStatus = SessionTokensDB.check(credentialsToken);
	if (authorizationStatus !== "valid") {
		const response = new ServiceResponse(
			false,
			401,
			`Access denied, ${authorizationStatus}`
		);

		return (res
			.status(response.statusCode)
			.set("WWW-Authenticate", 'Bearer realm="api"')
			.json(response.get())
		);
	}
}

export default validateBearerToken;