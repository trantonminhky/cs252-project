const crypto = require('crypto');

const ServiceResponse = require('../helper/ServiceResponse');

const LoginDB = require('../db/LoginDB');
const SessionTokensDB = require('../db/SessionTokensDB');

function generateToken32() {
	return crypto.randomBytes(24).toString('base64url').slice(0, 32);
}

// TO-DO: IMPLEMENT PASSWORD ENCRYPTION INSTEAD OF PLAINTEXT STORAGE
/**
 * 
 */
class ProfileService {
	async register(user, pass) {
		if (!user || !pass) {
			return (new ServiceResponse(
				false,
				400,
				"Username or password is required"
			).get());
		}

		if (LoginDB.has(user)) {
			response.success = false;
			response.statusCode = 409;
			response.data = "Username already taken (CONFLICT)";
			return response;
		}

		const token = generateToken32();
		const tokenCreatedAt = Date.now();

		try {
			LoginDB.set(user, {
				username: user,
				password: pass,
				sessionToken: {
					data: token,
					createdAt: tokenCreatedAt
				}
			});

			SessionTokensDB.set(token, {
				username: user,
				createdAt: tokenCreatedAt
			});

			response.success = true;
			response.data = {
				username: LoginDB.get(user, 'username'),
				password: LoginDB.get(user, 'password'),
				sessionToken: {
					data: LoginDB.get(user, 'sessionToken.data'),
					createdAt: LoginDB.get(user, 'sessionToken.createdAt')
				}
			}

			return response;
		} catch (err) {
			response.success = false;
			response.statusCode = 500;
			response.data = "Something went wrong (INTERNAL_SERVER_ERROR)";
			return response;
		}
	}

	async login(user, pass) {
		if (!user || !pass) {
			throw new Error('User or pass is required');
		}

		try {
			const response = {}
			const password = LoginDB.get(user, 'password');

			if (!password) { // if this user does not exist
				response.success = false;
				response.data = "NO_USER_FOUND";
			} else if (password !== pass) { // if password mismatch
				response.success = false;
				response.data = "WRONG_PASSWORD";
			} else {
				const oldCreatedAt = LoginDB.get(user, "sessionToken.createdAt");
				let oldToken = LoginDB.get(user, "sessionToken.data");
				let newToken = generateToken32();
				let newCreatedAt = Date.now();

				if (SessionTokensDB.check(oldToken) !== "valid") { // if token expires
					LoginDB.set(user, newToken, "sessionToken.data");
					LoginDB.set(user, newCreatedAt, "sessionToken.createdAt");

					SessionTokensDB.set(newToken, {
						username: user,
						createdAt: newCreatedAt
					});
					SessionTokensDB.delete(oldToken);
				} else {
					newToken = LoginDB.get(user, "sessionToken.data");
					newCreatedAt = oldCreatedAt;
				}

				response.success = true;
				response.data = {
					token: newToken,
					createdAt: (new Date(newCreatedAt)).toString()
				}
			}

			return response;
		} catch (err) {
			console.error(err);
		}
	}

	async clear() {
		try {
			LoginDB.clear();
			return "Clear success";
		} catch (err) {
			console.error(err);
		}
	}
}

module.exports = new ProfileService();