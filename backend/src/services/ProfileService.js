import { randomBytes, randomUUID } from 'crypto';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

import ServiceResponse from '../helper/ServiceResponse.js';

import UserDB from '../db/UserDB.js';
import SessionTokensDB from '../db/SessionTokensDB.js';
import { issueSessionToken, validateSessionToken } from './auth/sessionTokenValidator.js';

const SALT_ROUNDS = 10;

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
		if (UserDB.findIndex(user => user.username === username)) {
			const response = new ServiceResponse(
				false,
				409,
				"Username already taken"
			);
			return response;
		}

		const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

		const userID = randomUUID();

		try {
			UserDB.set(userID, {
				username: username,
				password: passwordHash,
				name: name,
				age: age,
				preferences: [],
				preferencesVector: null,
				type: type,
				savePlaces: []
			});

			const data = {
				userID: userID
			}

			const response = new ServiceResponse(
				true,
				201,
				"Success",
				data
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
	async login(username, password) {
		// if this user does not exist
		const userID = UserDB.findIndex(user => user.username === username);
		if (!userID) {
			const response = new ServiceResponse(
				false,
				404,
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

		try {
			const accessToken = jwt.sign({
				sub: userID,
				name: UserDB.get(userID, 'name')
			}, process.env.JWT_SECRET, { expiresIn: "1h" });

			const response = new ServiceResponse(
				true,
				200,
				"Success",
				{
					userID: userID,
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

	async refresh(sessionToken) {
		const validated = await validateSessionToken(sessionToken);
		if (!validated) {
			const response = new ServiceResponse(
				false,
				401,
				"Validation of session token failed"
			);
			return response;
		}

		const oldTokenID = validated.tokenID;
		SessionTokensDB.delete(oldTokenID);

		const newSessionToken = await issueSessionToken(validated.userID);
		const accessToken = jwt.sign({
			sub: validated.userID,
			name: UserDB.get(validated.userID, 'name')
		}, process.env.JWT_SECRET, { expiresIn: "1h" });

		const response = new ServiceResponse(
			true,
			200,
			"Success",
			{	
				sessionToken: newSessionToken,
				accessToken: accessToken
			}
		)

		return response;
	}

	async getUser(userID) {
		if (!UserDB.has(userID)) {
			const response = new ServiceResponse(
				false,
				404,
				"User not found"
			);
			return response;
		}

		const data = UserDB.get(userID);
		delete data.password;
		delete data.preferencesVector;

		const response = new ServiceResponse(
			true,
			200,
			"Success",
			data
		);
		return response;
	}

	/**
		 * Updates user preferences.
		 * @param {String} token - Session token
		 * @param {Array|Object} preferences - The preferences data to save
		 * @returns {Promise<ServiceResponse>} Response
		 */
	async setPreferences(userID, preferences) {
		if (!UserDB.has(userID)) return new ServiceResponse(false, 404, "User not found");

		// let currentPrefs = UserDB.get(username, "preferences");
		// if (!Array.isArray(currentPrefs)) {
		// 	UserDB.set(username, [], "preferences");
		// }

		UserDB.set(userID, preferences, "preferences");
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
	async addSavedPlace(userID, placeID) {
		if (!UserDB.has(userID)) {
			return new ServiceResponse(false, 404, "User not found");
		}

		let savedPlaces = UserDB.ensure(userID, [], "savePlaces");

		// Check for duplicates
		if (savedPlaces.includes(placeID)) {
			return new ServiceResponse(
				false,
				409,
				"Place already saved"
			);
		}

		UserDB.push(userID, placeID, "savePlaces");

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
	async removeSavedPlace(userID, placeID) {
		if (!UserDB.has(userID)) {
			return new ServiceResponse(
				false,
				404,
				"User not found"
			);
		}

		let savedPlace = UserDB.ensure(userID, "savePlaces");

		if (!savedPlace.includes(placeID)) {
			return new ServiceResponse(
				false,
				409,
				"No saved place found"
			);
		}

		UserDB.remove(userID, placeID, "savePlaces");

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
	async getSavedPlaces(userID) {
		if (!UserDB.has(userID)) {
			return new ServiceResponse(false, 404, "User not found");
		}

		let places = UserDB.ensure(userID, [], "savePlaces");

		return new ServiceResponse(
			true,
			200,
			"Success",
			places
		);
	}
}

export default new ProfileService();