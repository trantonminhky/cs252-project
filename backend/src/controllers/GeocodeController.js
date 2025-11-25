const geocodeService = require('../services/GeocodeService');
const SessionTokensDB = require('../db/SessionTokensDB');
const ServiceResponse = require('../helper/ServiceResponse');

// TO-DO: DOCUMENT CONTROLLER CLASSES
class GeocodeController {
	// Geocode an address
	async geocode(req, res, next) {
		try {
			const { address, credentials } = req.query;

			// if no credentials are specified
			if (!credentials) {
				const response = new ServiceResponse(
					false,
					401,
					"Access denied, no credentials"
				);

				return res.status(response.statusCode).json(response.get());
			}

			// if the credentials are invalid
			let authorizationStatus = SessionTokensDB.check(credentials);
			if (authorizationStatus !== "valid") {
				const response = new ServiceResponse(
					false,
					401,
					`Access denied, ${authorizationStatus}`
				);

				return res.status(response.statusCode).json(response.get());
			}

			// if no address is specified
			if (!address) {
				const response = new ServiceResponse(
					false,
					400,
					"Address parameter is required"
				);

				return res.status(response.statusCode).json(response.get());
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