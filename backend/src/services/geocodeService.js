// src/services/geocode/geocode.js
const axios = require('axios');
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
	 * @returns {Response} Response 
	 */
	async geocode(query, limit = 5) {
		if (!query) {
			throw new Error('Geocode query is required');
		}
		try {
			const url = `${this.baseUrl}/geocoding/${encodeURIComponent(query)}.json`;
			const resp = await axios.get(url, {
				params: {
					key: this.apiKey,
					limit
				}
			});
			return resp.data;
		} catch (err) {
			throw new Error(`Geocoding failed: ${err.message}`);
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