const DBService = require('../services/DBService');

class DBController {
	async get(req, res, next) {
		try {
			const response = await DBService.get()
			res.status(200).json({
				success: true,
				data: response
			});
		} catch (err) {
			next(err)
		}
	}
}

module.exports = new DBController();