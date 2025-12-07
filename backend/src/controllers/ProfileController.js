import ServiceResponse from '../helper/ServiceResponse.js';
import ProfileService from '../services/ProfileService.js';
import { issueSessionToken } from '../services/auth/sessionTokenValidator.js';

function validateEmail(email) {
	return email
		.toLowerCase()
		.match(
			/^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
		);
}

// TO-DO: DOCUMENT CONTROLLER CLASSES
class ProfileController {
	async register(req, res, next) {
		try {
			const username = req.body.username;
			const email = req.body.email;
			const password = req.body.password;
			const name = req.body.name;
			const age = req.body.age;
			const type = req.body.type;

			if (!email || !password) {
				const response = new ServiceResponse(
					false,
					400,
					`Email or password is required`
				);

				return void res.status(response.statusCode).json(response.get());
			}

			if (!validateEmail(email)) {
				const response = new ServiceResponse(
					false,
					400,
					`Email is invalid`
				);

				return void res.status(response.statusCode).json(response.get());
			}

			if (!username || !name || !age) {
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

			return void res.status(response.statusCode).set("Location", `/api/profile/${response.payload.data.userID}`).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	async login(req, res, next) {
		try {
			const email = req.body.email;
			const password = req.body.password;
			const staySignedIn = req.body.staySignedIn;

			if (!email || !password) {
				const response = new ServiceResponse(
					false,
					400,
					"Email or password is required"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.login(email, password);

			if (staySignedIn) {
				const userID = response.payload.data.userID;
				const sessionToken = await issueSessionToken(userID);
				res.cookie("sessionToken", sessionToken, {
					httpOnly: true,
					secure: false,
					sameSite: "strict",
					path: "/api/profile/refresh"
				});
			}

			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async refresh(req, res, next) {
		try {
			const sessionToken = req.cookies.sessionToken;

			const response = await ProfileService.refresh(sessionToken);
			if (response.success) {
				res.cookie("sessionToken", response.payload.data.sessionToken, {
					httpOnly: true,
					secure: false,
					sameSite: "strict",
					path: "/api/profile/refresh"
				});
			}

			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async getUser(req, res, next) {
		try {
			const userID = req.params.userID;

			if (!userID) {
				const response = new ServiceResponse(
					false,
					404,
					"Route not found"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.getUser(userID);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async setPreferences(req, res, next) {
		try {
			const { userID, preferences } = req.body;

			if (!userID) {
				const response = new ServiceResponse(
					false,
					400,
					"User ID is required"
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

			const response = await ProfileService.setPreferences(userID, preferences);
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
			const { userID, placeID } = req.body;

			if (!userID) {
				const response = new ServiceResponse(
					false,
					400,
					"User ID is required"
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

			const response = await ProfileService.addSavedPlace(userID, placeID);
			return void res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	async removeSavedPlace(req, res, next) {
		try {
			const { userID, placeID } = req.body;

			if (!userID || !placeID) {
				const response = new ServiceResponse(
					false,
					400,
					"User ID and place ID are required"
				);

				return void res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.removeSavedPlace(userID, placeID);
			return void res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	async getSavedPlaces(req, res, next) {
		try {
			const { userID } = req.query;

			if (!userID) {
				const response = new ServiceResponse(
					false,
					400,
					"User ID is required"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.getSavedPlaces(userID);
			return void res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}
}

export default new ProfileController();