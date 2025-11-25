const DBService = require('../services/DBService');

// TO-DO: DOCUMENT CONTROLLER CLASSES

class DBController {
	async export(req, res, next) {
		try {
			const { name } = req.query;

			if (!name) {
				return res.status(400).json({
					success: false,
					statusCode: 400,
					payload: {
						message: 'Database name is required (BAD_REQUEST)',
						data: null
					}
				});
			}

			const response = await DBService.export(name);
			res.status(response.statusCode).json(response);
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