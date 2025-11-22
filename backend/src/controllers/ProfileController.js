const ProfileService = require('../services/ProfileService');

// TO-DO: DOCUMENT CONTROLLER CLASSES
class ProfileController {
	async register(req, res, next) {
		try {
			const user = req.body.username;
			const pass = req.body.password;
			
			if (!user || !pass) {
				return res.status(400).json({
					success: false,
					error: { message: 'Username or password is required (BAD_REQUEST)' }
				});
			}

			const response = await ProfileService.register(user, pass);

			res.status(response.statusCode).json(response);
		} catch (error) {
			next(error);
		}
	}

	async login(req, res, next) {
		try {
			const { username, password } = req.query;

			if (!username || !password) {
				return res.status(400).json({
					success: false,
					error: { message: 'Username or password is required (BAD_REQUEST)' }
				});
			}

			const response = await ProfileService.login(username, password);
			res.status(response.statusCode).json(response);
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
			res.status(response.statusCode).json(response);
		} catch (err) {
			next(err);
		}
	}
}

module.exports = new ProfileController();