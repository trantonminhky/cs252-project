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

	delete(key, path) {
		try {
			this.db.delete(key, path);
			// console.log(`SessionTokensDB delete key=${key}`);
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
		try {
			const exp = this.db.export();
			return exp;
		} catch (err) {
			console.error(err);
		}
	}
}

export default new CacheDB();