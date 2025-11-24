const DBService = require('../services/DBService');

// TO-DO: DOCUMENT CONTROLLER CLASSES

class DBController {
	async exportAll(req, res, next) {
		try {
			const response = await DBService.exportAll()
			res.status(200).json(response);
		} catch (err) {
			next(err)
		}
	}
}

module.exports = new DBController();