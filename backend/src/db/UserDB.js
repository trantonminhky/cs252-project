/*
	{
		user1: {
			"username": "username",
			"password": "password",
			sessionToken: {
				"data": "sessionTokenValue",
				"createdAt": "milliseconds"
			}
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
			// console.log(`UserDB set key=${key} val=${JSON.stringify(val)} success at path ${path}`);
		} catch (err) {
			console.error(err);
		}
	}

	get(key, path) {
		try {
			const value = this.db.get(key, path);
			// console.log(`UserDB get key=${key} returns ${value}`)
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