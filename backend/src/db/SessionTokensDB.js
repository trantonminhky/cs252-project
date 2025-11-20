/*
	{
		"token1": {
			"username": "username",
			"createdAt": "milliseconds"
		}
	}
*/



class SessionTokensDB {
	constructor() {
		import('enmap').then(async ({ default: Enmap }) => {
			this.db = new Enmap({ name: 'SessionTokensDB' });
		});
	}

	set(key, val, path) {
		try {
			this.db.set(key, val, path);
			console.log(`SessionTokensDB set key=${key} val=${JSON.stringify(val)} success at path ${path}`);
		} catch (err) {
			console.error(err);
		}
	}

	get(key, path) {
		try {
			const value = this.db.get(key, path);
			console.log(`SessionTokensDB get key=${key} returns ${value}`)
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
}

module.exports = new SessionTokensDB();