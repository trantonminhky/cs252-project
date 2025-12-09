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
	 * Service function for <code>/api/profile/register</code>. Creates a new user. On success, the <code>Location</code> header in the response contains a URI to the user data. Supports <code>POST</code> requests.
	 * @param {String} email - User's email. One email can only one correspond to one account
	 * @param {String} password - User's password. The password will be stored as a one-way bcrypt hash
	 * @param {String} name - User's personal name
	 * @param {String} age - User's age
	 * @param {String} type - What the user is registering as (tourist, business, etc.)
	 * @param {String} username - User's username. Note that username is not unique
	 * @returns {Promise<ServiceResponse>} Response
	 * 
	 * @example <caption>cURL</caption>
	 * curl -X POST \
	 * --header 'Content-Type: application/json' \
	 * --data '{"email":"therealmiku39@gmail.com","username":"therealmiku","password":"m3g4-S3CU12E-p455VV012d","name":"Hatsune Miku","age":18,"type":"tourist"}' \
	 * http://localhost:3000/api/profile/register
	 * 
	 * @example <caption>Response</caption>
	 * {
	 *	"success": true,
	 *	"statusCode": 201,
	 *	"payload": {
	 *		"message": "Success (CREATED)",
	 *		"data": {
	 *			"userID": "167612d0-8bf1-4b64-95ee-23887bb8d026"
	 *		}
	 *	}
	 * }
	 * 
	 * @property {CREATED} 201 - Successful request 
	 * @property {BAD_REQUEST} 400 - Missing any of the required parameters, email is not an invalid email, username is not alphanumeric (must only contains a-z, A-Z, 0-9), or password is not valid (must only contains a-z, A-Z, 0-9, !@#$%^&*()_-+={}[]|\\:;"'<>,.?/~`)
	 * @property {METHOD_NOT_ALLOWED} 405 - The endpoint does not support the HTTP method specified
	 * @property {CONFLICT} 409 - An account already exists with the given email
	 * @property {UNSUPPORTED_MEDIA} 415 - Request does not have <code>Content-Type:application/json</code> header
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
	 */
	async register(email, username, password, name, age, type) {
		if (UserDB.findIndex(user => user.email === email)) {
			const response = new ServiceResponse(
				false,
				409,
				"This email already has an account"
			);
			return response;
		}

		const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

		const userID = randomUUID();
		const discriminant = Math.floor(Math.random() * 10000).toString().padStart(4, '0');

		try {
			UserDB.set(userID, {
				username: username,
				discriminant: discriminant,
				email: email,
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
	 * Service function for <code>/api/profile/login</code>. Returns an access token for a user (and set persistent session token for the user if opted). Supports <code>POST</code> request.
	 * @param {String} email - User's email
	 * @param {String} password - User's password
	 * @param {Boolean} staySignedIn - Whether the user wants to keep their profile logged in persistently. If enabled, a cookie with the user session token is set
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl -X POST \
	 * --header 'Content-Type:application/json' \
	 * --data '{"email":"therealmiku39@gmail.com","password":"m3g4-S3CU12E-p455VV012d"}' \
	 * http://localhost:3000/api/profile/login
	 * 
	 * @example <caption>Response</caption>
	 * {
	 *	"success": true,
	 *	"statusCode": 200,
	 *	"payload": {
	 *		"message": "Success (OK)",
	 *		"data": {
	 *			"userID": "167612d0-8bf1-4b64-95ee-23887bb8d026",
	 *			"token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxNjc2MTJkMC04YmYxLTRiNjQtOTVlZS0yMzg4N2JiOGQwMjYiLCJuYW1lIjoiSGF0c3VuZSBNaWt1IiwiaWF0IjoxNzY1MjUzMTMyLCJleHAiOjE3NjUyNTY3MzJ9.8LSD9w9Wr5lhDc7TQLWmVaKeNljx1fjtvhOoFvr9q4s"
	 *		}
	 *	}
	 * }
	 * 
	 * @property {OK} 200 - Successful request
	 * @property {BAD_REQUEST} 400 - Missing email or password
	 * @property {UNAUTHORIZED} 401 - Wrong password
	 * @property {NOT_FOUND} 404 - No user associated with this email is found
	 * @property {METHOD_NOT_ALLOWED} 405 - The endpoint does not support the HTTP method specified
	 * @property {UNSUPPORTED_MEDIA} 415 - Request does not have <code>Content-Type:application/json</code> header
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
	 */

	async login(email, password, staySignedIn) {
		// if this user does not exist
		const userID = UserDB.findIndex(user => user.email === email);
		if (!userID) {
			const response = new ServiceResponse(
				false,
				404,
				"There is no account associated with this email"
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

	/**
	 * Service function for <code>/api/profile/refresh</code>. Refreshes the user's access token. Will always fail if <code>staySignedIn</code> was not checked during the login phase. The frontend is thus expected to then prompts the user to login again. Supports <code>POST</code> requests.
	 * @param {String} sessionToken - Bundled session token ID with the raw token. <b>The client need not tamper with this, as it is automatically stored in the cookies</b>
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl -X POST \
	 * --header 'Content-Type:application/json' \
	 * --cookie 'sessionToken=1b3523fa-e122-4510-84dd-2fa6c5155a99%3A52ad70f4-d0d6-4d2c-80a3-73c72389d76a' \
	 * http://localhost:3000/api/profile/refresh
	 * 
	 * @example <caption>Response</caption>
	 * {
	 *	"success": true,
	 *	"statusCode": 200,
	 *	"payload": {
	 *		"message": "Success (OK)",
	 *		"data": {
	 *			"sessionToken": "1b3523fa-e122-4510-84dd-2fa6c5155a99:52ad70f4-d0d6-4d2c-80a3-73c72389d76a",
	 *			"accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxNjc2MTJkMC04YmYxLTRiNjQtOTVlZS0yMzg4N2JiOGQwMjYiLCJuYW1lIjoiSGF0c3VuZSBNaWt1IiwiaWF0IjoxNzY1MjU0NDQ2LCJleHAiOjE3NjUyNTgwNDZ9.KSfNWbQPvn8YL08LdKjSYB5qjm-0z0IX5LXtRwGIcAE"
	 *		}
	 *	}
	 * }
	 * 
	 * @property {OK} 200 - Successful request
	 * @property {UNAUTHORIZED} 401 - The user did not enabled <code>staySignedIn</code> or the token was tampered with
	 * @property {METHOD_NOT_ALLOWED} 405 - The endpoint does not support the HTTP method specified
	 * @property {UNSUPPORTED_MEDIA} 415 - Request does not have <code>Content-Type:application/json</code> header
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
	 */
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

	/**
	 * Service function for <code>/api/profile/:userID</code>. Get user's info given user ID. Supports <code>GET</code> requests.
	 * @param {String} userID - User's UUID
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl http://localhost:3000/api/profile/167612d0-8bf1-4b64-95ee-23887bb8d026
	 * 
	 * @example <caption>Response</caption>
	 * {
	 * 	"success": true,
	 * 	"statusCode": 200,
	 * 	"payload": {
	 * 		"message": "Success (OK)",
	 * 		"data": {
	 * 			"username": "therealmiku",
	 * 			"discriminant": "2516",
	 * 			"email": "therealmiku39@gmail.com",
	 * 			"name": "Hatsune Miku",
	 * 			"age": 18,
	 * 			"preferences": [],
	 * 			"type": "tourist",
	 * 			"savePlaces": []
	 * 		}
	 * 	}
	 * }
	 */
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

		let savedPlace = UserDB.ensure(userID, [], "savePlaces");

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