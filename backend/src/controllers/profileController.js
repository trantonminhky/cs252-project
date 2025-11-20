const ProfileService = require('../services/profileService');

class ProfileController {
	async register(req, res, next) {
		try {
			const user = req.body.username;
			const pass = req.body.password;		
			console.log(user);
			console.log(pass);
			
			if (!user || !pass) {
				return res.status(400).json({
					success: false,
					error: { message: 'user or pass is required' }
				});
			}

			const result = await ProfileService.register(user, pass);

			res.status(201).json({
				success: true,
				data: result
			});
		} catch (error) {
			next(error);
		}
	}

	async login(req, res, next) {
		try {
			const { user, pass } = req.query;

			if (!user || !pass) {
				return res.status(400).json({
					success: false,
					error: { message: 'user or pass is required' }
				});
			}

			const response = await ProfileService.login(user);
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