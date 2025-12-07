/*
	{
		"geocode": [
			{
				"address": "van hanh mall",
				"data": { ... },
				"createdAt": 123456789
			}
		],
		"reverse_geocode": [
			{
				"lat": 6.767,
				"lon": 7,676,
				"data": { ... },
				"createdAt": 123456789
			}
		]
	}
*/

import Enmap from 'enmap';
import unwrapTyped from '../helper/unwrapTyped.js';

class CacheDB {
	constructor() {
		this.db = new Enmap({ name: 'CacheDB' });
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

	findGeocode(query) {
		const caches = this.db.ensure('geocode', []);
		let result = caches.find(entry => entry.address === query);
		if (result == null) {
			return null;
		} else {
			return result;
		}
	}

	upsertGeocode(data) {
		const caches = this.db.ensure('geocode', []);
		const i = caches.findIndex(x => x.name === data.name);
		if (i !== -1) {
			this.db.set('geocode', data, i)
		} else {
			this.db.push('geocode', data);
		}
	}

	findReverseGeocode(lat, lon) {
		const caches = this.db.ensure('reverse_geocode', []);
		let result = caches.find(entry => entry.lat === lat && entry.lon === lon);
		if (result == null) {
			return null;
		} else {
			return result;
		}
	}

	upsertReverseGeocode(data) {
		const caches = this.db.ensure('reverse_geocode', []);

		// find if cache have the result query
		const i = caches.findIndex(x => x.lat === data.lat && x.lon === data.lon);
		if (i !== -1) { // if yes, then update
			this.db.set('reverse_geocode', data, i)
		} else { // if no, then insert
			this.db.push('reverse_geocode', data);
		}
	}

	findRoute(coordinates, profile) {
		const caches = this.db.ensure('route', []);
		let result = caches.find(entry => entry.coordinates === coordinates && entry.profile === profile);
		if (result == null) {
			return null;
		} else {
			return result;
		}
	}

	upsertRoute(data) {
		const caches = this.db.ensure('route', []);
		const i = caches.findIndex(x => x.coordinates === data.coordinates && x.profile === data.profile);
		if (i !== -1) {
			this.db.set('route', data, i)
		} else {
			this.db.push('route', data);
		}
	}

	findNearby(lat, lon, radius, category_ids) {
		const caches = this.db.ensure('nearby', []);
		let result = caches.find(entry => entry.lat === lat && entry.lon === lon && entry.radius === radius && entry.category_ids === category_ids);
		if (result == null) {
			return null;
		} else {
			return result;
		}
	}

	upsertNearby(data) {
		const caches = this.db.ensure('nearby', []);
		const i = caches.findIndex(x => x.lat === data.lat && x.lon === data.lon && x.radius === data.radius && x.category_ids === data.category_ids);
		if (i !== -1) {
			this.db.set('nearby', data, i)
		} else {
			this.db.push('nearby', data);
		}
	}

	delete(key, path) {
		try {
			this.db.delete(key, path);
		} catch (err) {
			console.error(err);
		}
	}

	push(key, value, path, allowDupes = false) {
		try {
			this.db.push(key, value, path, allowDupes);
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

export default new CacheDB();