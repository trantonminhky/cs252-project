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


class LoginDB {
	constructor() {
		import('enmap').then(async ({ default: Enmap }) => {
			this.db = new Enmap({ name: 'LoginDB' });
		});
	}

	set(key, val, path) {
		try {
			this.db.set(key, val, path);
			// console.log(`LoginDB set key=${key} val=${JSON.stringify(val)} success at path ${path}`);
		} catch (err) {
			console.error(err);
		}
	}

	get(key, path) {
		try {
			const value = this.db.get(key, path);
			// console.log(`LoginDB get key=${key} returns ${value}`)
			return value;
		} catch (err) {
			console.error(err);
		}
	}

	has(key) {
		try {
			const value = this.db.has(key);;
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

module.exports = new LoginDB();