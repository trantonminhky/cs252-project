// src/services/geocode/geocode.js
import axios from 'axios';

import ServiceResponse from '../helper/ServiceResponse.js';
import config from '../config/config.js';
import CacheDB from '../db/CacheDB.js';

const CACHE_LIFETIME_MS = 86400000; // 1 day

/**
 * Geocode service provider class.
 * @class
 */
class GeocodeService {
	constructor() {
		this.baseUrl = config.openStreetMap.baseURL;
	}

	/**
	 * Sends query to OpenMapTiles to return geocoded address.
	 * @param {string} query - Address to query OpenMapTiles
	 * @param {number} [limit=5] - Maximum number of results returned. Default is 5
	 * @returns {Promise<ServiceResponse>} Response 
	 */
	async geocode(query) {
		const cache = CacheDB.findGeocode(query);

		if (cache && Date.now() - cache.createdAt < CACHE_LIFETIME_MS) {
			// if the result is already stored in cache and hasn't expired
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				cache.data
			);
			return response;
		} else {
			const url = `${this.baseUrl}/search`;
			const axiosResponse = await axios.get(url, {
				params: {
					format: 'jsonv2',
					q: query
				}
			});

			CacheDB.upsertGeocode({
				address: query,
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
		}
	}

	/**
	 * Sends latitude and longitude to OpenMapTiles to get reverse-geocoded address.
	 * @param {Number} lat - Latitude
	 * @param {Number} lon - Longitude
	 * @returns {Promise<ServiceResponse>} Response
	 */
	async reverseGeocode(lat, lon) {
		const cache = CacheDB.findReverseGeocode(lat, lon);

		if (cache && Date.now() - cache.createdAt < CACHE_LIFETIME_MS) {
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				cache.data
			);
			return response;
		} else {
			const url = `${this.baseUrl}/reverse?format=jsonv2&lat=${lat}&lon=${lon}`;
			const axiosResponse = await axios.get(url, {
				params: {
					format: 'jsonv2',
					lat: lat,
					lon: lon
				}
			});

			CacheDB.upsertReverseGeocode({
				lat: lat,
				lon: lon,
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
		}
	}
}

export default new GeocodeService();