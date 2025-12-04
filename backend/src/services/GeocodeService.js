// src/services/geocode/geocode.js
import axios from 'axios';

import ServiceResponse from '../helper/ServiceResponse.js';
import config from '../config/config.js';

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
	async geocode(query, limit = 5) {
		const url = `${this.baseUrl}/search`;
		const resp = await axios.get(url, {
			params: {
				format: 'jsonv2',
				q: query
			}
		});

		const response = new ServiceResponse(
			true,
			200,
			"Success",
			resp.data
		);
		return response;
	}

	/**
	 * Sends latitude and longitude to OpenMapTiles to get reverse-geocoded address.
	 * @param {Number} lat - Latitude
	 * @param {Number} lon - Longitude
	 * @returns {Promise<ServiceResponse>} Response
	 */
	async reverseGeocode(lat, lon) {
		const url = `${this.baseUrl}/reverse?format=jsonv2&lat=${lat}&lon=${lon}`;
		const resp = await axios.get(url);

		const response = new ServiceResponse(
			true,
			200,
			"Success",
			resp.data
		);
		return response;
	}
}

export default new GeocodeService();