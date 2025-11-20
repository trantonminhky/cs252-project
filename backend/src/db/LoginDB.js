class LoginDB {
	constructor() {
		import('enmap').then(async ({ default: Enmap }) => {
			this.db = new Enmap({ name: 'LoginDB' });
		});
	}

	set(key, val) {
		try {
			this.db.set(key, val);
			console.log(`LoginDB set key=${key} val=${JSON.stringify(val)} success`);
		} catch (err) {
			console.error(err);
		}
	}

	get(key, path) {
		try {
			const value = this.db.get(key, path);
			console.log(`LoginDB get key=${key} returns ${value}`)
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

module.exports = new LoginDB();