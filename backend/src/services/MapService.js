import axios from 'axios';
import config from '../config/config.js';
import ServiceResponse from '../helper/ServiceResponse.js';
import CacheDB from '../db/CacheDB.js';

const MAP_CACHE_LIFETIME_MS = 120000; // 2 minutes

/**
 * Map service provider class.
 * @class
 */
class MapService {
	constructor() {
		this.APIKey = config.openRouteService.APIKey;
		this.baseURL = config.openRouteService.baseURL;
	}

	// Get route between two points
	// param - array of [lon,lat] pairs
	// return - route data
	async getRoute(coordinates, profile = 'driving-car') {
		const cache = CacheDB.findRoute(coordinates, profile);

		if (cache && Date.now() - cache.createdAt < MAP_CACHE_LIFETIME_MS) {
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				cache.data
			);
			return response;
		}

		const fromCoordinates = coordinates[0].map(coor => coor.toString()).join(',');
		const toCoordinates = coordinates[1].map(coor => coor.toString()).join(',');

		try {
			const url = `${this.baseURL}/v2/directions/${profile}`;
			const axiosResponse = await axios.get(url, {
				params: {
					api_key: this.APIKey,
					start: fromCoordinates,
					end: toCoordinates
				}
			});

			CacheDB.upsertRoute({
				coordinates: coordinates,
				profile: profile,
				data: axiosResponse.data,
				createdAt: Date.now()
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
		let filters = {};

		if (category_ids.length) {
			filters.category_ids = category_ids;
		}

		try {
			const url = `${this.baseURL}/pois`;
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
					Authorization: this.APIKey
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