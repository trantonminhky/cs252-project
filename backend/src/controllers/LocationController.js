const ServiceResponse = require('../helper/ServiceResponse');
const LocationService = require('../services/LocationService');

class LocationController {
	async importToDB(req, res, next) {
		await LocationService.importToDB();
		res.status(200).json("lol");
	}

	async search(req, res, next) {
		try {
			const { query } = req.query;
			if (!query) {
				const response = new ServiceResponse(
					false,
					200,
					"Query is required"
				);
				return res.status(response.statusCode).json(response.get());
			}

			const response = await LocationService.search(query);
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

module.exports = new LocationController();