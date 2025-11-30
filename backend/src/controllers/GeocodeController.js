const geocodeService = require('../services/GeocodeService').default;
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
				const response = new ServiceResponse(
					false,
					401,
					"Access denied, no credentials"
				);

				return res.status(response.statusCode).json(response.get());
			}

			let authorizationStatus = SessionTokensDB.check(credentials);
			if (authorizationStatus !== "valid") {
				const response = new ServiceResponse(
					false,
					401,
					`Access denied, ${authorizationStatus}`
				);

				return res.status(response.statusCode).json(response.get());
			}

			if (!lat || !lon) {
				const response = new ServiceResponse(
					false,
					400,
					`Latitude and longitude parameters are required`
				);

				return res.status(response.statusCode).json(response.get());
			}

			const response = await geocodeService.reverseGeocode(parseFloat(lat), parseFloat(lon));

			res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}
}

module.exports = new GeocodeController();