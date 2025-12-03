import ServiceResponse from '../helper/ServiceResponse.js';
import mapService from '../services/MapService.js';
import SessionTokensDB from '../db/SessionTokensDB.js';

// TO-DO: DOCUMENT CONTROLLER CLASSES

class MapController {
	// Get route between points
	async getRoute(req, res, next) {
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

			const { coordinates, profile } = req.body;

			if (!coordinates) {
				const response = new ServiceResponse(
					false,
					400,
					"Coordinates are required"
				);
				return res.status(response.statusCode).json(response.get());
			}

			if (!Array.isArray(coordinates)) {
				const response = new ServiceResponse(
					false,
					400,
					"Coordinates must be expressed as an array of 2 coordinate pairs"
				);
				return res.status(response.statusCode).json(response.get());
			}

			if (coordinates.length != 2) {
				const response = new ServiceResponse(
					false,
					400,
					"Only two pairs of coordinates must be specified"
				);
				return res.status(response.statusCode).json(response.get());
			}

			const response = await mapService.getRoute(coordinates, profile);
			res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	// Search nearby place
	async nearby(req, res, next) {
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

			const lat = req.body.lat;
			const lon = req.body.lon;
			const radius = req.body.radius;
			const category_ids = req.body.category_ids;

			if (lat == null || lon == null) {
				const response = new ServiceResponse(
					false,
					400,
					"Latitude and longitude are required"
				);
				return res.status(response.statusCode).json(response.get());
			}

			const response = await mapService.nearby(lat, lon, radius, category_ids);
			res.status(response.statusCode).json(response.get());

		} catch (error) {
			next(error);
		}
	}
};

export default new MapController();