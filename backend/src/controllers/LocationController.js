const LocationService = require('../services/LocationService');

class LocationController {
	async importToDB(req, res, next) {
		await LocationService.importToDB();
		res.status(200).json("lol");
	}
}

module.exports = new LocationController();