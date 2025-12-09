import FuzzySearch from 'fuzzy-search';

import LocationDB from '../db/LocationDB.js';
import architecturesData from '../../architecture.json' with { type: "json" };
import ServiceResponse from '../helper/ServiceResponse.js';
import config from '../config/config.js';
import axios from 'axios';
import FormData from 'form-data';

/**
 * Location service provider class.
 * @class
 */
class LocationService {
	constructor() {
		this.baseURLAn = config.pythonBackend.baseURLAn
		this.baseURLVan = config.pythonBackend.baseURLVan
		this.baseURLImageVan = config.pythonBackend.baseURLImageVan
	}

	/**
	 * Developer's function import to DB. No endpoint of this will be made.
	 */
	async importToDB() {
		for (const entry of architecturesData) {
			if (entry.id == null) continue;
			LocationDB.set(entry.id.toString(), {
				id: entry.id,
				lat: entry.lat,
				lon: entry.lon,
				name: entry.name,
				age: entry.age,
				tags: entry.tags,
				imageLink: entry.image_link,
				description: entry.description,
				openHours: entry.open_hours,
				dayOff: entry.day_off
			});
			console.log(entry.open_hours);
		}

		const response = new ServiceResponse(
			true,
			201,
			"Success"
		);
		return response;
	}

	/**
	 * Search a point of interest based on name, description, latitudes and longitudes.
	 * @param {String} query - Query to input
	 * @param {Object} [filters] - Filters
	 * @param {Number} [initialK=10] - Number of results returned in the first round
	 * @param {Number} [finalK=3] - Number of results returned in the second round
	 * 
	 * @return {Promise<ServiceResponse>} Response
	 */
	async search(query, filters, initialK = 10, finalK = 3) {
		const axiosResponse = await axios.post(`${this.baseURLAn}/search`, {
			query: query,
			filters: filters,
			initial_k: initialK,
			final_k: finalK
		}, {
			headers: {
				'Content-Type': 'application/json'
			}
		});

		const response = new ServiceResponse(
			true,
			200,
			"Success",
			axiosResponse.data.data
		);
		return response;
	}

	async searchByImage(fileBuffer, filename = "image.jpg") {
		const form = new FormData();
		form.append("file", fileBuffer, filename);
		form.append("limit", "5");

		const headers = form.getHeaders();

		const axiosResponse = await axios.post(
			`${this.baseURLImageVan}/search`,
			form,
			{ headers }
		);

		const response = new ServiceResponse(
			true,
			200,
			"Success",
			axiosResponse.data
		);

		return response;
	}

	async getLocation(locationID) {
		if (!LocationDB.has(locationID)) {
			const response = new ServiceResponse(
				false,
				404,
				"Location ID not found"
			);
			return response;
		}

		const result = LocationDB.get(locationID);
		const response = new ServiceResponse(
			true,
			200,
			"Success",
			result
		);
		return response;
	}
}

export default new LocationService();