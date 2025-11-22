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
	 * @param {number|undefined} limit - Maximum number of results returned
	 * @returns {ServiceResponse} Response 
	 */
	async geocode(query, limit = 5) {

		// if no query is specified
		if (!query) {
			return (new ServiceResponse(
				success = false,
				statusCode = 400,
				message = "Query is required"
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
				success = true,
				statusCode = 200,
				message = "Success",
				data = resp.data
			);
			return response.get();
		} catch (err) {
			return new ServiceResponse(
				success = false,
				statusCode = 500,
				message = "Something went wrong"
			)
		}
	}

	// Reverse geocode (lat, lon) -> returns response.data from MapTiler
	async reverseGeocode(lat, lon) {
		if (lat == null || lon == null) {
			throw new Error('Latitude and longitude are required for reverse geocoding');
		}
		try {
			const url = `${this.baseUrl}/geocoding/${lon},${lat}.json`;
			const resp = await axios.get(url, {
				params: {
					key: this.apiKey
				}
			});
			return resp.data;
		} catch (err) {
			throw new Error(`Reverse geocoding failed: ${err.message}`);
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