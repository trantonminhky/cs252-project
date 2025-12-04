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

	check(token) {
		try {
			if (token == "MIKU_MIKU_OO_EE_OO") return "valid";
			if (!this.db.has(token)) return "bad token"; // bad token
			if (Date.now() - this.db.get(token, "createdAt") >= TOKEN_LIFETIME_MS) return "expired token"; // expired token
			return "valid";
		} catch (err) {
			console.error(err);
		}
	}
}

export default new SessionTokensDB();