import { randomBytes, randomUUID } from 'crypto';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

import ServiceResponse from '../helper/ServiceResponse.js';

import UserDB from '../db/UserDB.js';
import SessionTokensDB from '../db/SessionTokensDB.js';

import { issueSessionToken, validateSessionToken } from './auth/sessionTokenValidator.js'

const SALT_ROUNDS = 10;

function generateToken32() {
	return randomBytes(24).toString('base64url').slice(0, 32);
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

/**
 * Profile service provider class.
 * @class
 */
class ProfileService {
	/**
	 * Registers a user to a new profile given username and password.
	 * @param {String} username - Username
	 * @param {String} password - Password
	 * @returns {Promise<ServiceResponse>} Response
	 */
	async register(username, password, name, age, type) {
		if (UserDB.has(username)) {
			const response = new ServiceResponse(
				false,
				409,
				"Username already taken"
			);
			return void res.status(response.statusCode).json(response.get());
		}

		const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

		const userID = randomUUID();
		const token = generateToken32(); // user session token
		const tokenCreatedAt = Date.now(); // session token created timestamp in ms

		try {
			UserDB.set(userID, {
				username: username,
				password: passwordHash,
				name: name,
				age: age,
				preferences: [],
				preferencesVector: null,
				type: type,
				sessionToken: {
					data: token,
					createdAt: tokenCreatedAt
				},
				savePlaces: []
			});

			SessionTokensDB.set(token, {
				username: username,
				createdAt: tokenCreatedAt
			});

			const response = new ServiceResponse(
				true,
				201,
				"Success",
				{
					token: UserDB.get(username, 'sessionToken.data'),
					createdAt: (new Date(UserDB.get(username, 'sessionToken.createdAt'))).toString()
				}
			);

			return response;
		} catch (err) {
			console.error(err);
			return (new ServiceResponse(
				false,
				500,
				"Something went wrong"
			));
		}
	}

	/**
	 * Logins a user.
	 * @param {String} username - Username
	 * @param {String} password - Password
	 * @returns {Promise<ServiceResponse>} Response
	 */
	async login(username, password, staySignedIn) {
		// if this user does not exist
		const userID = UserDB.findIndex(user => user.username === username);
		if (!userID) {
			const response = new ServiceResponse(
				false,
				401,
				"Username does not exist"
			);
			return response;
		}

		const passwordMatch = await bcrypt.compare(password, UserDB.get(userID, 'password'));
		if (!passwordMatch) {
			const response = new ServiceResponse(
				false,
				401,
				"Wrong password"
			);
			return response;
		}

		if (staySignedIn) {
			const sessionToken = await issueSessionToken(userID);
			res.cookie('sessionToken', sessionToken, {
				httpOnly: true,
				secure: true,
				sameSite: 'strict',
				path: '/refresh'
			});
		}

		try {
			const accessToken = jwt.sign({
				sub: userID,
				name: UserDB.get(userID, 'name')
			}, process.env.JWT_SECRET);

			const response = new ServiceResponse(
				true,
				200,
				"Success",
				{
					token: accessToken
				}
			)

			return response;
		} catch (err) {
			console.error(err);
			return (new ServiceResponse(
				false,
				500,
				"Something went wrong"
			));
		}
	}
	/**
		 * Updates user preferences.
		 * @param {String} token - Session token
		 * @param {Array|Object} preferences - The preferences data to save
		 * @returns {Promise<ServiceResponse>} Response
		 */
	async setPreferences(username, preferences) {
		if (!UserDB.has(username)) return new ServiceResponse(false, 404, "Username not found");

		// let currentPrefs = UserDB.get(username, "preferences");
		// if (!Array.isArray(currentPrefs)) {
		// 	UserDB.set(username, [], "preferences");
		// }

		UserDB.set(username, preferences, "preferences");
		return new ServiceResponse(
			true,
			201,
			"Success"
		);
	}
	/**
	 * Adds a place to the user's saved list.
	 * @param {String} username - The username
	 * @param {String|Number} placeID - The ID of the place to save
	 * @returns {Promise<ServiceResponse>}
	 */
	async addSavedPlace(username, placeID) {
		if (!UserDB.has(username)) {
			return new ServiceResponse(false, 404, "User not found");
		}

		let savedPlaces = UserDB.ensure(username, [], "savePlaces");

		// Check for duplicates
		if (savedPlaces.includes(placeID)) {
			return new ServiceResponse(
				false,
				409,
				"Place already saved"
			);
		}

		UserDB.push(username, placeID, "savePlaces");

		return new ServiceResponse(
			true,
			200,
			"Place saved successfully"
		);
	}

	/**
	 * Removes a place from the user's saved list.
	 * @param {String} username - The username
	 * @param {String|Number} placeID - The ID of the place to remove
	 * @returns {Promise<ServiceResponse>}
	 */
	async removeSavedPlace(username, placeID) {
		if (!UserDB.has(username)) {
			return new ServiceResponse(
				false,
				404,
				"User not found"
			);
		}

		let savedPlace = UserDB.ensure(username, "savePlaces");

		if (!savedPlace.includes(placeID)) {
			return new ServiceResponse(
				false,
				409,
				"No saved place found"
			);
		}

		UserDB.remove(username, placeID, "savePlaces");

		return new ServiceResponse(
			true,
			200,
			"Place removed successfully"
		);
	}

	/**
	 * Gets the list of saved places for a user.
	 * @param {String} username 
	 * @returns {Promise<ServiceResponse>}
	 */
	async getSavedPlaces(username) {
		if (!UserDB.has(username)) {
			return new ServiceResponse(false, 404, "User not found");
		}

		let places = UserDB.ensure(username, [], "savePlaces");

		return new ServiceResponse(
			true,
			200,
			"Success",
			places
		);
	}
}

export default new ProfileService();