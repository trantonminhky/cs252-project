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

	async getLocation(req, res, next) {
		try {
			const locationID = req.params.locationID;

			if (locationID === ':locationID') {
				const response = new ServiceResponse(
					false,
					404,
					"Route not found"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await LocationService.getLocation(locationID);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new LocationController();