const DBService = require('../services/DBService');

// TO-DO: DOCUMENT CONTROLLER CLASSES

class DBController {
	async get(req, res, next) {
		try {
			const response = await DBService.get()
			res.status(200).json(response);
		} catch (err) {
			next(err)
		}
	}
}

module.exports = new DBController();