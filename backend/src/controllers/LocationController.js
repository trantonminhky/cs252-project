import ServiceResponse from '../helper/ServiceResponse.js';
import LocationService from '../services/LocationService.js';

class LocationController {
	async importToDB(req, res, next) {
		await LocationService.importToDB();
		res.status(200).json("lol");
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
			res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new LocationController();