import ServiceResponse from '../helper/ServiceResponse.js';
import LocationService from '../services/LocationService.js';
import LocationDB from '../db/LocationDB.js';

class LocationController {
	async importToDB(req, res, next) {
		try {
			const response = await LocationService.importToDB();
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err)
		}
	}

	async search(req, res, next) {
		try {
			const { query, filters, initialK, finalK } = req.body;
			const response = await LocationService.search(query, filters, initialK, finalK);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async findByID(req, res, next) {
		try {
			const { id } = req.query;

			if (id == null) {
				const response = new ServiceResponse(
					false,
					400,
					"Location ID is required"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await LocationService.findByID(id);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new LocationController();