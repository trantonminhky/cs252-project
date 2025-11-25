const geocodeService = require('../services/GeocodeService');
const SessionTokensDB = require('../db/SessionTokensDB');

// TO-DO: DOCUMENT CONTROLLER CLASSES
class GeocodeController {
	// Geocode an address
	async geocode(req, res, next) {
		try {
			const { address, credentials } = req.query;

			if (!credentials) {
				return res.status(401).json({
					success: false,
					error: { message: 'Access denied, no credentials (UNAUTHORIZED)' }
				})
			}

			let authorizationStatus = SessionTokensDB.check(credentials);
			if (authorizationStatus !== "valid") {
				return res.status(401).json({
					success: false,
					error: { message: `Access denied, ${authorizationStatus} (UNAUTHORIZED)` }
				});
			}

			if (!address) {
				return res.status(400).json({
					success: false,
					error: { message: 'Address parameter is required (BAD_REQUEST)' }
				});
			}

			const response = await geocodeService.geocode(address);

			res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	// Reverse geocode coordinates
	async reverseGeocode(req, res, next) {
		try {
			const { lat, lon, credentials } = req.query;

			if (!credentials) {
				return res.status(401).json({
					success: false,
					error: { message: 'Access denied, no credentials (UNAUTHORIZED)' }
				})
			}

			let authorizationStatus = SessionTokensDB.check(credentials);
			if (authorizationStatus !== "valid") {
				return res.status(401).json({
					success: false,
					error: { message: `Access denied, ${authorizationStatus} (UNAUTHORIZED)` }
				});
			}

			if (!lat || !lon) {
				return res.status(400).json({
					success: false,
					error: { message: 'Latitude and longtitude parameters are required (BAD_REQUEST)' }
				});
			}

			const response = await geocodeService.reverseGeocode(parseFloat(lat), parseFloat(lon));

			res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}
}

module.exports = new GeocodeController();