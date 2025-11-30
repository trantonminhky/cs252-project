import FuzzySearch from 'fuzzy-search';

import LocationDB from '../db/LocationDB.js';
import architecturesData from '../../architecture.json' with { type: "json" };
import ServiceResponse from '../helper/ServiceResponse.js';

function unwrapTyped(x) {
	if (Array.isArray(x)) return x.map(unwrapTyped);

	if (x && typeof x === "object") {
		const keys = Object.keys(x);
		if (keys.length === 2 && keys.includes("t") && keys.includes("v")) {
			return unwrapTyped(x.v);
		}
		const out = {};
		for (const k of keys) out[k] = unwrapTyped(x[k]);
		return out;
	}

	return x;
}

class LocationService {
	async importToDB() {
		for (const entry of architecturesData) {
			if (!entry.Key) continue;
			LocationDB.set(entry.Key, {
				id: entry.ID,
				lat: entry["location.lat"],
				lon: entry["location.lon"],
				name: entry.name,
				buildingType: entry.building_type.split(', '),
				archStyle: entry.arch_style.split(', '),
				religion: entry.religion != 'none' ? entry.religion.split(', ') : [],
				imageLink: entry['image link'],
				description: entry.description,
			});
			console.log(`set entry ${entry.ID} successfully`);
		}
	}

	async search(query, { include } = {}) {
		const searchAllResults = query === "" || query == null;
		const searchAllTags = include == null;

		if (!Array.isArray(include) && !searchAllTags) {
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
			const tagsList = entry.value.buildingType
			.concat(entry.value.archStyle)
			.concat(entry.value.religion);

			return tagsList.some(tag => include.includes(tag));
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