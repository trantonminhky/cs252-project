/*
	{
		"token1": {
			"username": "username",
			"createdAt": "milliseconds"
		}
	},
	...
*/

import Enmap from 'enmap';
import unwrapTyped from '../helper/unwrapTyped.js';
const TOKEN_LIFETIME_MS = 1800000;


class SessionTokensDB {
	constructor() {
		this.db = new Enmap({ name: 'SessionTokensDB' });
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

export default new SessionTokensDB();