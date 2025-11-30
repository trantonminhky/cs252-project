const FuzzySearch = require('fuzzy-search');

const LocationDB = require('../db/LocationDB');
const architecturesData = require('../../architecture.json');
const ServiceResponse = require('../helper/ServiceResponse');

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
				religion: 'none' ? entry.religion.split(', ') : [],
				imageLink: entry['image link'],
				description: entry.description,
			});
			console.log(`set entry ${entry.ID} successfully`);
		}
	}

	async search(query, tags) {
		if (!query) {
			const response = new ServiceResponse(
				false,
				400,
				"Query is required"
			);
			return response;
		}

		const parse = JSON.parse(LocationDB.export());
		const haystack = {};
		for (const entry of parse.v.keys.v) {
			haystack[entry.v.key.v] = unwrapTyped(JSON.parse(entry.v.value.v));
		}
		const locationSearcher = new FuzzySearch(haystack, ['lat', 'lon', 'name', 'description']);
		const result = locationSearcher.search(query);
		const response = new ServiceResponse(
			true,
			200,
			"Success",
			result
		);
		return response;
	}
}

module.exports = new LocationService();