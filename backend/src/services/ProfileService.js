const crypto = require('crypto');

const ServiceResponse = require('../helper/ServiceResponse');

const UserDB = require('../db/UserDB');
const SessionTokensDB = require('../db/SessionTokensDB');

function generateToken32() {
	return crypto.randomBytes(24).toString('base64url').slice(0, 32);
}

function renewToken(user) {
	const oldCreatedAt = UserDB.get(user, "sessionToken.createdAt");
	const oldToken = UserDB.get(user, "sessionToken.data");
	let newToken = generateToken32();
	let newCreatedAt = Date.now();

	if (SessionTokensDB.check(oldToken) !== "valid") { // if token expires
		UserDB.set(user, newToken, "sessionToken.data");
		UserDB.set(user, newCreatedAt, "sessionToken.createdAt");

		SessionTokensDB.set(newToken, {
			username: user,
			createdAt: newCreatedAt
		});
		SessionTokensDB.delete(oldToken);
	} else {
		newToken = UserDB.get(user, "sessionToken.data");
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
		if (UserDB.has(user)) {
			return (new ServiceResponse(
				false,
				409,
				"Username already taken"
			).get());
		}

		const token = generateToken32(); // user session token
		const tokenCreatedAt = Date.now(); // session token created timestamp in ms

		try {
			UserDB.set(user, {
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
					token: UserDB.get(user, 'sessionToken.data'),
					createdAt: (new Date(UserDB.get(user, 'sessionToken.createdAt'))).toString()
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
	async login(user, pass, name, age) {
		// if no username or password is provided
		if (!user || !pass) {
			return (new ServiceResponse(
				false,
				400,
				"Username or password is required"
			).get());
		}
		
		// if no name or age
		if (!name || !age) { 
			return (new ServiceResponse(
				false,
				400,
				"Missing user info"
			).get());
		}

		const password = UserDB.get(user, 'password');
		// if this user does not exist
		if (!password) { 
			return (new ServiceResponse(
				false,
				401,
				"Username does not exist"
			).get());
		}

		// if password mismatch
		if (password !== pass) { 
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
			UserDB.clear();
			return (new ServiceResponse(
				true,
				200,
				"Success"
			));
		} catch (err) {
			console.error(err);
			return (new ServiceResponse(
				false,
				500,
				"Something went wrong"
			).get());
		}
	}
}

module.exports = new ProfileService();