const ServiceResponse = require('../helper/ServiceResponse');
const LocationService = require('../services/LocationService').default;

class LocationController {
	async importToDB(req, res, next) {
		await LocationService.importToDB();
		res.status(200).json("lol");
	}

	async search(req, res, next) {
		try {
			const { query, exclude } = req.query;
			if (!query) {
				const response = new ServiceResponse(
					false,
					200,
					"Query is required"
				);
				return res.status(response.statusCode).json(response.get());
			}

			let excludeOption;
			if (exclude) {
				excludeOption = exclude.split(',');
			}

			const response = await LocationService.search(query, {
				exclude: excludeOption
			});
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

module.exports = new LocationController();