// src/services/geocode/geocode.js
const axios = require('axios');

const ServiceResponse = require('../helper/ServiceResponse');
const config = require('../config/config').default;

/**
 * Geocode service provider class.
 * @class
 */
class GeocodeService {
	constructor() {
		this.baseUrl = config.openStreetMap.baseUrl;
	}

	/**
	 * Sends query to OpenMapTiles to return geocoded address.
	 * @param {string} query - Address to query OpenMapTiles
	 * @param {number} [limit=5] - Maximum number of results returned. Default is 5
	 * @returns {Promise<ServiceResponse>} Response 
	 */
	async geocode(query, limit = 5) {

		// if no query is specified
		if (!query) {
			return (new ServiceResponse(
				false,
				400,
				"Query is required"
			));
		}

		try {
			const url = `${this.baseUrl}/search`;
			const resp = await axios.get(url, { params: {
				format: 'jsonv2',
				q: query
			}});
			
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				resp.data
			);
			return response;
		} catch (err) {
			console.log(err);
			return new ServiceResponse(
				false,
				500,
				"Something went wrong"
			);
		}
	}

	/**
	 * Sends latitude and longitude to OpenMapTiles to get reverse-geocoded address.
	 * @param {Number} lat - Latitude
	 * @param {Number} lon - Longitude
	 * @returns {Promise<ServiceResponse>} Response
	 */
	async reverseGeocode(lat, lon) {
		// if latitudes and longitudes are not provided
		if (lat == null || lon == null) {
			return (new ServiceResponse(
				false,
				400,
				"Latitude and longitude are required"
			));
		}

		try {
			const url = `${this.baseUrl}/reverse?format=jsonv2&lat=${lat}&lon=${lon}`;
			const resp = await axios.get(url);

			const response = new ServiceResponse(
				true,
				200,
				"Success",
				resp.data
			);
			return response;
		} catch (err) {
			console.log(err);
			return (new ServiceResponse(
				false,
				500,
				"Something went wrong"
			));
		}
	}

	// Optional helper — return the best match (first feature) or null
	getBestFeature(geocodeResponse) {
		if (!geocodeResponse || !Array.isArray(geocodeResponse.features) || geocodeResponse.features.length === 0) {
			return null;
		}
		return geocodeResponse.features[0];
	}
}

module.exports = new GeocodeService();