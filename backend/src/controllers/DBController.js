const DBService = require('../services/DBService');

// TO-DO: DOCUMENT CONTROLLER CLASSES

class DBController {
	async export(req, res, next) {
		try {
			const { name } = req.query.name;

			const response = await DBService.export(name);
			res.status(200).json(response);
		} catch (err) {
			next(err);
		}
	}

	async exportAll(req, res, next) {
		try {
			const response = await DBService.exportAll();
			res.status(200).json(response);
		} catch (err) {
			next(err);
		}
	}
}

module.exports = new DBController();