const LocationDB = require('./db/LocationDB');
const architecturesData = require('../architecture.json');

class LocationService {
	async importToDB() {
		for (const entry of architecturesData) {
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
}

module.exports = new LocationService();