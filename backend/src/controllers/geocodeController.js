const geocodeService = require('../services/geocodeService');

class GeocodeController {
	// Geocode an address
	async geocode(req, res, next) {
		try {
			const { address } = req.query;

			if (!address) {
				return res.status(400).json({
					success: false,
					error: { message: 'Address parameter is required' }
				});
			}

			const result = await geocodeService.geocode(address);

			res.json({
				success: true,
				data: result
			});
		} catch (error) {
			next(error);
		}
	}

	// Reverse geocode coordinates
	async reverseGeocode(req, res, next) {
		try {
			const { lat, lon } = req.query;

			if (!lat || !lon) {
				return res.status(400).json({
					success: false,
					error: { message: 'Latitude and longtitude parameters are required' }
				});
			}

			const result = await geocodeService.reverseGeocode(parseFloat(lat), parseFloat(lon));

			res.json({
				success: true,
				data: result
			});
		} catch (error) {
			next(error);
		}
	}
}

module.exports = new GeocodeController();