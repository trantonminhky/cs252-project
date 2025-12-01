import FuzzySearch from 'fuzzy-search';

import LocationDB from '../db/LocationDB.js';
import architecturesData from '../../architecture.json' with { type: "json" };
import ServiceResponse from '../helper/ServiceResponse.js';
import unwrapTyped from '../helper/unwrapTyped.js';

class LocationService {
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
	}

	/**
	 * Search a point of interest based on name, description, latitudes and longitudes.
	 * @param {String} query - Query to input
	 * @param {Object} [options] - Options
	 * @param {String[]|} [options.include] - Tags to only include in results so that each result has one or more tags included. By default all tags are included
	 * @return {Promise<ServiceResponse>} Response
	 */
	async search(query, options = {include: []}) {
		const searchAllResults = query === "" || query == null;
		const searchAllTags = options.include == null;

		if (!Array.isArray(options.include) && !searchAllTags) {
			const response = new ServiceResponse(
				false,
				400,
				"Malformed include option"
			);
			return response;
		}

		const parse = JSON.parse(LocationDB.export());
		const data = {};
		for (const entry of parse.v.keys.v) {
			data[entry.v.key.v] = unwrapTyped(JSON.parse(entry.v.value.v));
		}

		const haystack = Object.entries(data).map(([key, value]) => ({
			key,
			value
		}));

		let results;
		if (searchAllResults) {
			results = haystack;
		} else {
			const locationSearcher = new FuzzySearch(haystack, ['value.lat', 'value.lon', 'value.name', 'value.description']);
			results = locationSearcher.search(query);
		}

		results = results.filter(entry => {
			if (searchAllTags) return true;
			const tagsList = entry.value.tags.buildingType
			.concat(entry.value.tags.archStyle)
			.concat(entry.value.tags.religion);

			return tagsList.some(tag => options.include.includes(tag));
		});
		const response = new ServiceResponse(
			true,
			200,
			"Success",
			results
		);
		return response;
	}
}

export default new LocationService();