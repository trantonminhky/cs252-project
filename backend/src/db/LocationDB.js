/*
	{
		"0": {
			id: 0,
			lat: 69.696969
			lon: 36.363636
			name: "Great Statue of Lorem Ipsum",
			age: 420,
			tags: {
				religion: ["christianity"],
				buildingType: ["restaurant"],
				archStyle: ["gothic"],
				foodType: ["italian"]
			},
			imageLink: "https://example.com",
			description: "Lorem ipsum dolor sit amet",
			openHours: ["0600", "1100", "1300", "2000"],
			dayOff: "saturday, sunday"
		} 
	}, ...
*/

import Enmap from 'enmap';
import unwrapTyped from '../helper/unwrapTyped.js';

class LocationDB {
	constructor() {
		this.db = new Enmap({ name: 'LocationDB' });

	}

	set(key, val, path) {
		try {
			this.db.set(key, val, path);
		} catch (err) {
			console.error(err);
		}
	}

	get(key, path) {
		try {
			const value = this.db.get(key, path);
			return value;
		} catch (err) {
			console.error(err);
		}
	}

	delete(key, path) {
		try {
			this.db.delete(key, path);
		} catch (err) {
			console.error(err);
		}
	}

	clear() {
		try {
			this.db.clear();
		} catch (err) {
			console.error(err);
		}
	}

	has(key) {
		try {
			return this.db.has(key);
		} catch (err) {
			console.error(err);
		}
	}

	export() {
		const data = {};
		const parse = JSON.parse(this.db.export());
		const name = parse.v.name.v;
		for (const entry of parse.v.keys.v) {
			data[entry.v.key.v] = unwrapTyped(JSON.parse(entry.v.value.v));
		}
		return {
			name: name,
			data: data
		};
	}
}

export default new LocationDB();