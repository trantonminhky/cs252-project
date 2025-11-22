const ProfileService = require('../services/profileService');

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
					error: { message: 'user or pass is required' }
				});
			}

			const response = await ProfileService.login(username, password);
			if (!response.success) {
				res.status(401).json({
					success: false,
					data: `Access Denied (${response.data})`
				})
			} else {
				res.status(200).json({
					success: true,
					data: response.data
				})
			}
		} catch (err) {
			next(err);
		}
	}

	async clear(req, res, next) {
		try {
			const response = await ProfileService.clear();
			res.json(response);
		} catch (err) {
			next(err);
		}
	}
}

module.exports = new ProfileController();