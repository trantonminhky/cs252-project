import ServiceResponse from '../helper/ServiceResponse';
import DBService from '../services/DBService';

// TO-DO: DOCUMENT CONTROLLER CLASSES

class DBController {
	async clear(req, res, next) {
		try {
			const { name } = req.query;

			if (!name) {
				const response = new ServiceResponse(
					false,
					400,
					`Database name is required`
				);

				return res.status(response.statusCode).json(response.get());
			}

			const response = await DBService.clear(name);
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async clearAll(req, res, next) {
		try {
			const response = await DBService.clearAll();
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async export(req, res, next) {
		try {
			const { name } = req.query;

			if (!name) {
				const response = new ServiceResponse(
					false,
					400,
					`Database name is required`
				);

				return res.status(response.statusCode).json(response.get());
			}

			const response = await DBService.export(name);
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async exportAll(req, res, next) {
		try {
			const response = await DBService.exportAll();
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new DBController();