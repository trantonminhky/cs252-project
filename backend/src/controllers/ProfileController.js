import ServiceResponse from '../helper/ServiceResponse.js';
import ProfileService from '../services/ProfileService.js';
import UserDB from '../db/UserDB.js';

// TO-DO: DOCUMENT CONTROLLER CLASSES
class ProfileController {
	async register(req, res, next) {
		try {
			const username = req.body.username;
			const password = req.body.password;
			const name = req.body.name;
			const age = req.body.age;
			const type = req.body.type;

			if (!username || !password) {
				const response = new ServiceResponse(
					false,
					400,
					`Username or password is required`
				);

				return void res.status(response.statusCode).json(response.get());
			}

			if (!name || !age) {
				const response = new ServiceResponse(
					false,
					400,
					"User info is required"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			if (!type) {
				const response = new ServiceResponse(
					false,
					400,
					"User type is required"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			if (!username.match(/^[0-9a-zA-Z]+$/)) {
				const response = new ServiceResponse(
					false,
					400,
					"Username must be alphanumeric"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			if (!password.match(/^[A-Za-z0-9!@#$%^&*()_\-+={}[\]|\\:;"'<>,.?/~`]+$/)) {
				const response = new ServiceResponse(
					false,
					400,
					"Password cannot contain special symbols"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.register(username, password, name, age);

			return void res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	async login(req, res, next) {
		try {
			const username = req.body.username;
			const password = req.body.password;
			const staySignedIn = req.body.staySignedIn;

			if (!username || !password) {
				const response = new ServiceResponse(
					false,
					400,
					"Username or password is required"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.login(username, password, staySignedIn);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
	async setPreferences(req, res, next) {
		try {
			const { username, preferences } = req.body;

			if (!username) {
				const response = new ServiceResponse(
					false,
					400,
					"Username is required"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			if (!preferences) {
				const response = new ServiceResponse(
					false,
					400,
					"Preferences data is required"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			if (!Array.isArray(preferences)) {
				const response = new ServiceResponse(
					false,
					400,
					"Malformed preferences"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.setPreferences(username, preferences);
			return void res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	async savedPlacesController(req, res, next) {
		if (req.method === 'GET') {
			this.getSavedPlaces(req, res, next);
		} else if (req.method === 'POST') {
			this.addSavedPlace(req, res, next)
		} else if (req.method === 'DELETE') {
			this.removeSavedPlace(req, res, next);
		}
	}

	async addSavedPlace(req, res, next) {
		try {
			const { username, placeId: placeID } = req.body;

			if (!username) {
				const response = new ServiceResponse(
					false,
					400,
					"Username is required"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			if (!placeID) {
				const response = new ServiceResponse(
					false,
					400,
					"Place ID is required"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.addSavedPlace(username, placeID);
			return void res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	async removeSavedPlace(req, res, next) {
		try {
			const { username, placeID } = req.body;

			if (!username || !placeID) {
				const response = new ServiceResponse(
					false,
					400,
					"Username and place ID are required"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.removeSavedPlace(username, placeID);
			return void res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	async getSavedPlaces(req, res, next) {
		try {
			const { username } = req.query;

			if (!username) {
				const response = new ServiceResponse(
					false,
					400,
					"Username is required"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.getSavedPlaces(username);
			return void res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}
}

export default new ProfileController();