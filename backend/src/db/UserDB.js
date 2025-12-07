/*
	{
		user-uuid: {
			"username": "username",
			"password": "passwordHashed",
			...
		}, ...
	}
*/

import Enmap from 'enmap';
import unwrapTyped from '../helper/unwrapTyped.js';

class UserDB {
	constructor() {
		this.db = new Enmap({ name: 'UserDB' });
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

	has(key) {
		try {
			const value = this.db.has(key);
			return value;
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

	remove(key, value, path) {
		try {
			this.db.remove(key, value, path);
		} catch (err) {
			console.error(err);
		}
	}

	find(pathOrFn, value) {
		try {
			return this.db.find(pathOrFn, value);
		} catch (err) {
			console.error(err);
		}
	}

	findIndex(pathOrFn, value) {
		try {
			return this.db.findIndex(pathOrFn, value);
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

export default new UserDB();