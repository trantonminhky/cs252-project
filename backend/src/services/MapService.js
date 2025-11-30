const axios = require('axios');
const config = require('../config/config');
const ServiceResponse = require('../helper/ServiceResponse');

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