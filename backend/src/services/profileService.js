const crypto = require('crypto');

const ServiceResponse = require('../helper/ServiceResponse');

const LoginDB = require('../db/LoginDB');
const SessionTokensDB = require('../db/SessionTokensDB');

function generateToken32() {
	return crypto.randomBytes(24).toString('base64url').slice(0, 32);
}

function renewToken(user) {
	const oldCreatedAt = LoginDB.get(user, "sessionToken.createdAt");
	const oldToken = LoginDB.get(user, "sessionToken.data");
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
	return {
		data: newToken,
		createdAt: newCreatedAt
	}
}

// TO-DO: IMPLEMENT PASSWORD ENCRYPTION INSTEAD OF PLAINTEXT STORAGE
/**
 * Profile service provider class.
 * @class
 */
class ProfileService {
	/**
	 * Registers a user to a new profile given username and password.
	 * @param {String} user - Username
	 * @param {String} pass - Password
	 * @returns {Object} Response
	 */
	async register(user, pass) {
		// if username or password is not provided
		if (!user || !pass) {
			return (new ServiceResponse(
				false,
				400,
				"Username or password is required"
			).get());
		}

		// if the username is already registered
		if (LoginDB.has(user)) {
			return (new ServiceResponse(
				false,
				409,
				"Username already taken"
			).get());
		}

		const token = generateToken32(); // user session token
		const tokenCreatedAt = Date.now(); // session token created timestamp in ms

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

			const response = new ServiceResponse(
				true,
				201,
				"Success",
				{
					token: LoginDB.get(user, 'sessionToken.data'),
					createdAt: (new Date(LoginDB.get(user, 'sessionToken.createdAt'))).toString()
				}
			);

			return response.get();
		} catch (err) {
			console.error(err);
			return (new ServiceResponse(
				false,
				500,
				"Something went wrong"
			).get());
		}
	}

	/**
	 * Logins a user.
	 * @param {String} user - Username
	 * @param {String} pass - Password
	 * @returns {Object} Response
	 */
	async login(user, pass) {
		// if no username or password is provided
		if (!user || !pass) {
			return (new ServiceResponse(
				false,
				400,
				"Username or password is required"
			).get());
		}

		const password = LoginDB.get(user, 'password');
		if (!password) { // if this user does not exist
			return (new ServiceResponse(
				false,
				401,
				"Username does not exist"
			).get());
		}

		if (password !== pass) { // if password mismatch
			return (new ServiceResponse(
				false,
				401,
				"Wrong password"
			).get());
		}

		try {
			const token = renewToken(user);
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				{
					token: token.data,
					createdAt: (new Date(token.createdAt)).toString()
				}
			)

			return response.get();
		} catch (err) {
			console.error(err);
			return (new ServiceResponse(
				false,
				500,
				"Something went wrong"
			).get());
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