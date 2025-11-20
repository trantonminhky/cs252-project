const ProfileService = require('../services/profileService');

class ProfileController {
	async test_set(req, res, next) {
		try {
			const { user } = req.query;

			if (!user) {
				return res.status(400).json({
					success: false,
					error: { message: 'user is required' }
				});
			}

			const result = await ProfileService.test_set(user);

			res.json({
				success: true,
				data: result
			});
		} catch (error) {
			next(error);
		}
	}

	async test_get(req, res, next) {
		try {
			const { user } = req.query;

			if (!user) {
				return res.status(400).json({
					success: false,
					error: { message: 'user is required' }
				});
			}

			const response = await ProfileService.test_get(user);
			res.json(response);
		} catch (err) {
			next(err);
		}
	}
}

module.exports = new ProfileController();