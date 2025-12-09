import ServiceResponse from '../helper/ServiceResponse.js';
import mapService from '../services/MapService.js';

class MapController {
	// Get route between points
	async getRoute(req, res, next) {
		try {
			const { coordinates, profile } = req.body;

			if (!coordinates) {
				const response = new ServiceResponse(
					false,
					400,
					"Coordinates are required"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			if (!Array.isArray(coordinates)) {
				const response = new ServiceResponse(
					false,
					400,
					"Coordinates must be expressed as an array of 2 coordinate pairs"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			if (coordinates.length != 2) {
				const response = new ServiceResponse(
					false,
					400,
					"Only two pairs of coordinates must be specified"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			if (coordinates.flat().some(coor => Number.isNaN(parseFloat(coor)))) {
				const response = new ServiceResponse(
					false,
					400,
					"Bad coordinates"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await mapService.getRoute(coordinates, profile);
			return void res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	// Search nearby place
	async nearby(req, res, next) {
		try {
			const r = new ServiceResponse(
				false,
				503,
				"OpenRouteService is FUCKING RETARDED"
			);
			return void res.status(r.statusCode).json(r.get());

			const lat = req.body.lat;
			const lon = req.body.lon;
			const radius = req.body.radius ?? 1000;
			let category_ids = req.body.category_ids;

			if (lat == null || lon == null) {
				const response = new ServiceResponse(
					false,
					400,
					"Latitude and longitude are required"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			if (radius <= 0 || radius > 2000) {
				const response = new ServiceResponse(
					false,
					400,
					"Radius must be over 0 and no more than 2000"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			if (category_ids != null && !Array.isArray(category_ids)) {
				const response = new ServiceResponse(
					false,
					400,
					"Malformed category id list"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await mapService.nearby(lat, lon, radius, category_ids);
			return void res.status(response.statusCode).json(response.get());

		} catch (error) {
			next(error);
		}
	}
};

export default new MapController();