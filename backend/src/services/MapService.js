import axios from 'axios';
import config from '../config/config.js';
import ServiceResponse from '../helper/ServiceResponse.js';

/**
 * Map service provider class.
 * @class
 */
class MapService {
	constructor() {
		this.apiKey = config.openRouteService.apiKey;
		this.baseUrl = config.openRouteService.baseUrl;
	}

	// Get route between two points
	// param - array of [lon,lat] pairs
	// return - route data
	async getRoute(coordinates, profile = 'driving-car') {
		if (coordinates.length !== 2) {
			const response = new ServiceResponse(
				false,
				400,
				"Only two pairs of coordinates must be specified"
			);
			return response;
		}

		if (Number.isNaN(parseFloat(coordinates[0][0])) || Number.isNaN(parseFloat(coordinates[0][1])) || Number.isNaN(parseFloat(coordinates[1][0])) || Number.isNaN(parseFloat(coordinates[1][1]))) {
			const response = new ServiceResponse(
				false,
				400,
				"Bad coordinates"
			);
			return response;
		}

		const fromCoordinates = coordinates[0].map(coor => coor.toString()).join(',');
		const toCoordinates = coordinates[1].map(coor => coor.toString()).join(',');

		try {
			const url = `${this.baseUrl}/directions/${profile}`;
			const axiosResponse = await axios.get(url, { params: {
				api_key: this.apiKey,
				start: fromCoordinates,
				end: toCoordinates
			}});

			const response = new ServiceResponse(
				true,
				200,
				"Success",
				axiosResponse.data
			);
			return response;
		} catch (err) {
			const response = new ServiceResponse(
				false,
				500,
				"Something went wrong"
			);
			return response;
		}
	}

	// Search for places near a location
	// params - lat, lon, rad, category
	// return - places data
	async nearby(lat, lon, radius = 1000, category_ids = []) {
		if (lat == null || lon == null) {
			const response = new ServiceResponse(
				false,
				400,
				"Latitude and longitude are required"
			);
			return response;
		}

		if (radius <= 0 || radius > 2000) {
			const response = new ServiceResponse(
				false,
				400,
				"Radius must be over 0 and no more than 2000"
			);
			return response;
		}

		if (!Array.isArray(category_ids)) {
			const response = new ServiceResponse(
				flse,
				400,
				"Malformed category id list"
			);
			return response;
		}

		try {
			const url = `${this.baseUrl}/pois`;
			const axiosResponse = await axios.post(url, {
				request: "pois",
				geometry: {
					geojson: {
						type: "Point",
						coordinates: [lat, lon]
					},
					buffer: radius
				},
				filters: {
					category_ids: category_ids
				}
			});
	
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				axiosResponse.data
			);
			return response;
		} catch (err) {
			console.error(err);
			const response = new ServiceResponse(
				false,
				500,
				"Something went wrong"
			);
			return response;
		}
	}
}

export default new MapService();