import axios from 'axios';
import config from '../config/config.js';
import ServiceResponse from '../helper/ServiceResponse.js';

/**
 * Map service provider class.
 * @class
 */
class MapService {
	constructor() {
		this.apiKey = config.openRouteService.APIKey;
		this.baseUrl = config.openRouteService.baseURL;
	}

	// Get route between two points
	// param - array of [lon,lat] pairs
	// return - route data
	async getRoute(coordinates, profile = 'driving-car') {
		if (coordinates.flat().some(coor => Number.isNaN(parseFloat(coor)))) {
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
			const url = `${this.baseUrl}/v2/directions/${profile}`;
			const axiosResponse = await axios.get(url, {
				params: {
					api_key: this.apiKey,
					start: fromCoordinates,
					end: toCoordinates
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
			const response = new ServiceResponse(
				false,
				502,
				"Something went wrong",
				err.toString()
			);
			return response;
		}
	}

	// Search for places near a location
	// params - lat, lon, rad, category
	// return - places data
	async nearby(lat, lon, radius = 1000, category_ids = []) {
		if (radius <= 0 || radius > 2000) {
			const response = new ServiceResponse(
				false,
				400,
				"Radius must be over 0 and no more than 2000"
			);
			return response;
		}

		let filters = {};

		if (!Array.isArray(category_ids)) {
			const response = new ServiceResponse(
				flse,
				400,
				"Malformed category id list"
			);
			return response;
		}

		if (category_ids.length) {
			filters.category_ids = category_ids;
		}

		try {
			const url = `${this.baseUrl}/pois`;
			const axiosResponse = await axios.post(url, {
				request: "pois",
				geometry: {
					geojson: {
						type: "Point",
						coordinates: [lon, lat]
					},
					buffer: radius
				},
				filters
			}, {
				headers: {
					Authorization: this.apiKey
				}
			});
	
			let resp;
			if (typeof axiosResponse.data === 'string' || axiosResponse.data instanceof String) {
				resp = {};
			} else {
				resp = axiosResponse.data;
			}
	
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				resp
			);
			return response;
		} catch (err) {
			const response = new ServiceResponse(
				false,
				502,
				"Something went wrong",
				err.toString()
			);
			return response;
		}
	}
}

export default new MapService();