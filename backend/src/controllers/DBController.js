import ServiceResponse from '../helper/ServiceResponse.js';
import DBService from '../services/DBService.js';

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

				return void res.status(response.statusCode).json(response.get());
			}

			const response = await DBService.clear(name);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async clearAll(req, res, next) {
		try {
			const response = await DBService.clearAll();
			return void res.status(response.statusCode).json(response.get());
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

				return void res.status(response.statusCode).json(response.get());
			}

			const response = await DBService.export(name);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async exportAll(req, res, next) {
		try {
			const response = await DBService.exportAll();
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new DBController();