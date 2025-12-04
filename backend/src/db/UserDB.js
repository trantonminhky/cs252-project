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

	export() {
		try {
			const exp = this.db.export();
			return exp;
		} catch (err) {
			console.error(err);
		}
	}
}

export default new UserDB();