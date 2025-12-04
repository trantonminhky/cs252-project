import ServiceResponse from '../helper/ServiceResponse.js';
import ProfileService from '../services/ProfileService.js';

// TO-DO: DOCUMENT CONTROLLER CLASSES
class ProfileController {
	async register(req, res, next) {
		try {
			const user = req.body.username;
			const pass = req.body.password;
			const name = req.body.name;
			const age = req.body.age;
			if (!user || !pass) {
				const response = new ServiceResponse(
					false,
					400,
					`Username or password is required`
				);

				return res.status(response.statusCode).json(response.get());
			}

			if (!name || !age) {
				const response = new ServiceResponse(
					false,
					400,
					"User info is required"
				);

				return res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.register(user, pass, name, age);

			res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	async login(req, res, next) {
		try {
			const username = req.body.username;
			const password = req.body.password;

			if (!username || !password) {
				const response = new ServiceResponse(
					false,
					400,
					"Username or password is required"
				);

				return res.status(response.statusCode).json(response.get());
			}

			const response = await ProfileService.login(username, password);
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
	async setPreferences(req, res, next) {
		try {
			const { username, preferences } = req.body;
			const response = await ProfileService.setPreferences(username, preferences);
			res.status(response.statusCode).json(response.get());
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
			const { username, placeId } = req.body;
			const response = await ProfileService.addSavedPlace(username, placeId);
			res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}
	async removeSavedPlace(req, res, next) {
		try {
			const { username, placeId } = req.body;
			const response = await ProfileService.removeSavedPlace(username, placeId);
			res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}
	async getSavedPlaces(req, res, next) {
		try {
			const { username } = req.query;
			const response = await ProfileService.getSavedPlaces(username);
			res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}
}

export default new ProfileController();