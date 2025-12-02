import { randomBytes } from 'crypto';

import ServiceResponse from '../helper/ServiceResponse.js';

import UserDB from '../db/UserDB.js';
import SessionTokensDB from '../db/SessionTokensDB.js';

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
	 * @returns {Promise<ServiceResponse>} Response
	 */
	async register(user, pass, name, age, isTourist) {
		// if username or password is not provided
		if (!user || !pass) {
			return (new ServiceResponse(
				false,
				400,
				"Username or password is required"
			));
		}

		// if no name or age is not provided
		if (!name || !age) {
			return (new ServiceResponse(
				false,
				400,
				"User info is required"
			));
		}

		// if the username is already registered
		if (UserDB.has(user)) {
			return (new ServiceResponse(
				false,
				409,
				"Username already taken"
			));
		}
		if(typeof isTourist === "boolean") 
		{
			return new ServiceResponse(false,400,"Malformed usertype parameter");
		}
		const token = generateToken32(); // user session token
		const tokenCreatedAt = Date.now(); // session token created timestamp in ms

		try {
			UserDB.set(user, {
				username: user,
				password: pass,
				name: name,
				age: age,
				preferences: [],
				rec_profile: null,
				isTourist: isTourist,
				sessionToken: {
					data: token,
					createdAt: tokenCreatedAt
				},
				savePlaces: []
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
	 * @param {String} user - Username
	 * @param {String} pass - Password
	 * @returns {Promise<ServiceResponse>} Response
	 */
	async login(user, pass) {
		// if no username or password is provided
		if (!user || !pass) {
			return (new ServiceResponse(
				false,
				400,
				"Username or password is required"
			));
		}

		const password = UserDB.get(user, 'password');
		// if this user does not exist
		if (!password) { 
			return (new ServiceResponse(
				false,
				401,
				"Username does not exist"
			));
		}

		// if password mismatch
		if (password !== pass) { 
			return (new ServiceResponse(
				false,
				401,
				"Wrong password"
			));
		}

		try {
			const token = renewToken(user);
			const isTourist = UserDB.get(user, 'isTourist');
			const preferences = UserDB.get(user, 'preferences');
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				{
					token: token.data,
					createdAt: (new Date(token.createdAt)).toString(),
					isTourist: isTourist,
					preferences: preferences || []
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
            if (!username) {
                return new ServiceResponse(false, 400, "Username is required");
            }
			if(!Array.isArray(preferences))
			{
				return new ServiceResponse(false,400,"Malformed preferences");
			}
            if(!UserDB.has(username)) return new ServiceResponse(false, 404, "Username not found");
            let currentPrefs = UserDB.get(username, "preferences");
   			if (!Array.isArray(currentPrefs)) {
        		UserDB.set(username, [], "preferences");
    		}
    		if (!preferences) {
    			return new ServiceResponse(false, 400, "Preferences data is required");
    		}

    		try {
    			UserDB.set(username, preferences, "preferences");
    			return new ServiceResponse(
    				true,
    				201,
    				"Success"
    			);
    		} catch (err) {
    			console.error(err);
    			return new ServiceResponse(false, 500, "Something went wrong");
    		}
    }
	/**
	 * Adds a place to the user's saved list.
	 * @param {String} username - The username
	 * @param {String|Number} placeId - The ID of the place to save
	 * @returns {Promise<ServiceResponse>}
	 */
	async addSavedPlace(username, placeId) {
		if (!username) return new ServiceResponse(false, 400, "Username is required");
		if (!placeId) return new ServiceResponse(false, 400, "Place ID is required");
		if (!UserDB.has(username)) {
			return new ServiceResponse(false, 404, "User not found");
		}
		try {
			// REPLACED: UserDB.ensure(...) and UserDB.push(...)
			// FIX: Fetch the current array manually
			let savedPlaces = UserDB.get(username, "savePlaces");

			// If the array doesn't exist yet (or is null), initialize it
			if (!Array.isArray(savedPlaces)) {
				savedPlaces = [];
			}

			// Check for duplicates
			if (savedPlaces.includes(placeId)) {
				return new ServiceResponse(false, 409, "Place already saved");
			}

			// Add the new ID to the local array
			savedPlaces.push(placeId);

			// FIX: Save the updated array back to the DB using the available .set() method
			UserDB.set(username, savedPlaces, "savePlaces");

			return new ServiceResponse(true, 201, "Place saved successfully");
		} catch (err) {
			console.error(err);
			return new ServiceResponse(false, 500, "Failed to save place");
		}
	}

	/**
	 * Removes a place from the user's saved list.
	 * @param {String} username - The username
	 * @param {String|Number} placeId - The ID of the place to remove
	 * @returns {Promise<ServiceResponse>}
	 */
	async removeSavedPlace(username, placeId) {
		if (!username || !placeId) {
			return new ServiceResponse(false, 400, "Username and Place ID are required");
		}

		if (!UserDB.has(username)) {
			return new ServiceResponse(false, 404, "User not found");
		}

		try {
			// FIX: Fetch, Filter, then Set
			let savedPlaces = UserDB.get(username, "savePlaces");

			if (!Array.isArray(savedPlaces)) {
				return new ServiceResponse(false, 404, "No saved places found");
			}
			
			// Filter out the item
			const newSavedPlaces = savedPlaces.filter(id => id !== placeId);
			
			// Save the updated list back
			UserDB.set(username, newSavedPlaces, "savePlaces");

			return new ServiceResponse(true, 200, "Place removed successfully");
		} catch (err) {
			console.error(err);
			return new ServiceResponse(false, 500, "Failed to remove place");
		}
	}

	/**
	 * Gets the list of saved places for a user.
	 * @param {String} username 
	 * @returns {Promise<ServiceResponse>}
	 */
	async getSavedPlaces(username) {
		if (!username) return new ServiceResponse(false, 400, "Username is required");
		
		if (!UserDB.has(username)) {
			return new ServiceResponse(false, 404, "User not found");
		}

		try {
			// FIX: Just use .get() and handle the undefined case
			let places = UserDB.get(username, "savePlaces");
			
			if (!places) {
				places = [];
			}
			
			return new ServiceResponse(true, 200, "Success", places);
		} catch (err) {
			console.error(err);
			return new ServiceResponse(false, 500, "Failed to fetch saved places");
		}
	}
}

export default new ProfileService();