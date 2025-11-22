const axios = require('axios');
const config = require('../config/config');

// THESE SERVICES ARE SOMEWHAT OUTDATED
// TO-DO: DEAL WITH THESE FUCKERS

class MapService {
	constructor() {
		this.apiKey = config.maptiler.apiKey;
		this.baseUrl = config.maptiler.baseUrl;
	}

	// Get URL for displaying maps
	// param - Map style (streets, outdoor, satellite,...)
	// return - Tile URL and configuration
	getMapTileUrl(style = 'streets') {
		return {
			tilesUrl: `${this.baseUrl}/maps/${style}/{z}/{x}/{y}.png?key=${this.apiKey}`,
			attribution: 'MapTiler OpenStreetMap contributors',
			maxZoom: 18,
			minZoom: 0
		};
	}

	// Get route between two points
	// param - array of [lon,lat] pairs
	// return - route data
	async getRoute(coordinates, profile = 'driving') {
		try {
			const coords = coordinates.map(c => `${c[0]},$c{[1]}`).json(';');
			const response = await axios.get(`${this.baseUrl}/routing/${profile}/${coords}.json`, {
				params: {
					key: this.apiKey,
					overview: 'full',
					steps: true
				}
			});
			return response.data;
		} catch (error) {
			throw new Error(`Routing failed: ${error.message}`);
		}
	}

	// Search for places near a location
	// params - lat, lon, rad, category
	// return - places data
	async searchNearBy(lat, lon, radius = 5000, category = null) {
		try {
			const params = {
				key: this.apiKey,
				lat,
				lon,
				radius,
				limit: 20
			};

			if (category) {
				params.types = category;
			}

			const response = await axios.get(`${this.baseUrl}/geocoding/nearby.json`, {
				params
			});

			return response.data;
		} catch (error) {
			throw new Error(`Nearby search failed: ${error.message}`);
		}
	}

	// Get static map image
	// params - lat, lon, zoom, width, height
	// return - image url
	getStaticMapUrl(lat, lon, zoom = 14, width = 600, height = 400) {
		return `${this.baseUrl}/maps/streets/static/${lon},${lat},${zoom},${width}x${height}.png?key=${this.apiKey}`;
	}
}

module.exports = new MapService();