// src/services/geocode/geocode.js
const axios = require('axios');

const ServiceResponse = require('../helper/ServiceResponse');
const config = require('../config/config');

class GeocodeService {
	constructor() {
		this.apiKey = config.maptiler.apiKey;
		this.baseUrl = config.maptiler.baseUrl;
	}

	/**
	 * Sends query to OpenMapTiles to return geocoded address.
	 * @param {string} query - Address to query OpenMapTiles
	 * @param {number|undefined} limit - Maximum number of results returned. Default is 5
	 * @returns {Object} Response 
	 */
	async geocode(query, limit = 5) {

		// if no query is specified
		if (!query) {
			return (new ServiceResponse(
				false,
				400,
				"Query is required"
			).get());
		}

		try {
			const url = `${this.baseUrl}/geocoding/${encodeURIComponent(query)}.json`;
			const resp = await axios.get(url, {
				params: {
					key: this.apiKey,
					limit
				}
			});
			
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				resp.data
			);
			return response.get();
		} catch (err) {
			console.log(err);
			return new ServiceResponse(
				false,
				500,
				"Something went wrong"
			).get();
		}
	}

	/**
	 * Sends latitude and longitude to OpenMapTiles to get reverse-geocoded address.
	 * @param {Number} lat - Latitude
	 * @param {Number} lon - Longitude
	 * @returns {Object} Response
	 */
	async reverseGeocode(lat, lon) {
		// if latitudes and longitudes are not provided
		if (lat == null || lon == null) {
			return (new ServiceResponse(
				false,
				400,
				"Latitude and longitude are required"
			).get());
		}

		try {
			const url = `${this.baseUrl}/geocoding/${lon},${lat}.json`;
			const resp = await axios.get(url, {
				params: {
					key: this.apiKey
				}
			});

			const response = new ServiceResponse(
				true,
				200,
				"Success",
				resp.data
			);
			return response.get();
		} catch (err) {
			console.log(err);
			return (new ServiceResponse(
				false,
				500,
				"Something went wrong"
			).get());
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