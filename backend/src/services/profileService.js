const axios = require('axios');
const config = require('../config/config');
const crypto = require('crypto');

const LoginDB = require('../db/LoginDB');
const SessionTokensDB = require('../db/SessionTokensDB');
const { Session } = require('inspector');

function generateToken32() {
	return crypto.randomBytes(24).toString('base64url').slice(0, 32);
}

// TO-DO: IMPLEMENT PASSWORD ENCRYPTION INSTEAD OF PLAINTEXT STORAGE
class ProfileService {
	async register(user, pass) {
		if (!user || !pass) {
			throw new Error('User or pass is required');
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

			const response = {};
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
			throw new Error("failed");
		}
	}

	async login(user, pass) {
		if (!user || !pass) {
			throw new Error('User or pass is required');
		}

		try {
			const response = {}
			const password = LoginDB.get(user, 'password');

			if (!password) {
				response.success = false;
				response.data = "NO_USER_FOUND";
			} else if (password !== pass) {
				response.success = false;
				response.data = "WRONG_PASSWORD";
			} else {
				const createdAtMillisecond = LoginDB.get(user, "sessionToken.createdAt");
				if (Date.now() - createdAtMillisecond >= 1800000) { // if token lifetime is over 30 minutes
					LoginDB.set(user, token, "sessionToken.data");
					LoginDB.set(user, Date.now(), "sessionToken.createdAt");
				}
				const token = LoginDB.get(user, "sessionToken.data");

				response.success = true;
				response.data = {
					token: token,
					createdAt: (new Date(createdAtMillisecond)).toString()
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