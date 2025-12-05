import ServiceResponse from '../helper/ServiceResponse.js';
import LocationService from '../services/LocationService.js';

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
			const { query, include } = req.query;
			let includeOption;
			if (include) {
				includeOption = include.split(',');
			}

			const response = await LocationService.search(query, {
				include: includeOption
			});
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async findByID(req, res, next) {
		try {
			const { id } = req.query;
			const response = await LocationService.findByID(id);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new LocationController();