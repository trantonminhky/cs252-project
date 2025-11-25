const ServiceResponse = require('../helper/ServiceResponse');
const ProfileService = require('../services/ProfileService');

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
				const reponse = new ServiceResponse(
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
			const { username, password } = req.query;

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

	async clear(req, res, next) {
		try {
			// let's be real you are not gonna clear some random db without my credentials
			const { credentials } = req.query;

			if (!credentials) {
				return res.status(401).json({
					success: false,
					error: { message: 'Access denied, no credentials (UNAUTHORIZED)' }
				});
			}

			if (credentials !== process.env.DATABASE_CLEAR_CREDENTIALS) {
				return res.status(401).json({
					success: false,
					error: { message: 'Access denied, wrong credentials (UNAUTHORIZED)' }
				});
			}

			const response = await ProfileService.clear();
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

module.exports = new ProfileController();