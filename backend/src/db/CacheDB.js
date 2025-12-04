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
			// console.log(`SessionTokensDB set key=${key} val=${JSON.stringify(val)} success at path ${path}`);
		} catch (err) {
			console.error(err);
		}
	}

	get(key, path) {
		try {
			const value = this.db.get(key, path);
			// console.log(`SessionTokensDB get key=${key} returns ${value}`)
			return value;
		} catch (err) {
			console.error(err);
		}
	}

	findGeocode(query) {
		this.db.ensure('geocode', []);
		const caches = this.db.ensure('geocode', []);
		console.log(caches);
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

	delete(key, path) {
		try {
			this.db.delete(key, path);
			// console.log(`SessionTokensDB delete key=${key}`);
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