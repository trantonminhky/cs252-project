import geocodeService from '../services/GeocodeService.js';
import SessionTokensDB from '../db/SessionTokensDB.js';
import ServiceResponse from '../helper/ServiceResponse.js';

// TO-DO: DOCUMENT CONTROLLER CLASSES
class GeocodeController {
	// Geocode an address
	async geocode(req, res, next) {
		try {
			const bearerCredentials = req.headers["authorization"];

			// if no credentials are specified
			if (!bearerCredentials) {
				const response = new ServiceResponse(
					false,
					401,
					"Access denied, no credentials"
				);

				return (res
					.status(response.statusCode)
					.set("WWW-Authenticate", 'Bearer realm="api"')
					.json(response.get())
				);
			}

			const credentials = bearerCredentials.split(' '); // [scheme, token]
			if (credentials[0] !== 'Bearer') {
				const response = new ServiceResponse(
					false,
					401,
					"Access denied, authorization type must be Bearer"
				);

				return (res
					.status(response.statusCode)
					.set("WWW-Authenticate", 'Bearer realm="api"')
					.json(response.get())
				);
			}

			// if the credentials are invalid
			let authorizationStatus = SessionTokensDB.check(credentials[1]);
			if (authorizationStatus !== "valid") {
				const response = new ServiceResponse(
					false,
					401,
					`Access denied, ${authorizationStatus}`
				);

				return (res
					.status(response.statusCode)
					.set("WWW-Authenticate", 'Bearer realm="api"')
					.json(response.get())
				);
			}

			const { address } = req.query;
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
			const bearerCredentials = req.headers["authorization"];
			
			if (!bearerCredentials) {
				const response = new ServiceResponse(
					false,
					401,
					"Access denied, no credentials"
				);
				
				return (res
					.status(response.statusCode)
					.set("WWW-Authenticate", 'Bearer realm="api"')
					.json(response.get())
				);
			}

			const credentials = bearerCredentials.split(' '); // [scheme, token]
			if (credentials[0] !== 'Bearer') {
				const response = new ServiceResponse(
					false,
					401,
					"Access denied, authorization type must be Bearer"
				);

				return (res
					.status(response.statusCode)
					.set("WWW-Authenticate", 'Bearer realm="api"')
					.json(response.get())
				);
			}
			
			let authorizationStatus = SessionTokensDB.check(credentials[1]);
			if (authorizationStatus !== "valid") {
				const response = new ServiceResponse(
					false,
					401,
					`Access denied, ${authorizationStatus}`
				);
				
				return (res
					.status(response.statusCode)
					.set("WWW-Authenticate", 'Bearer realm="api"')
					.json(response.get())
				);
			}
			
			const { lat, lon } = req.query;
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

export default new GeocodeController();