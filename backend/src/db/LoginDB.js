class LoginDB {
	constructor() {
		import('enmap').then(async ({ default: Enmap }) => {
			this.db = new Enmap({ name: 'LoginDB' });
		});
	}

	set(key, val) {
		try {
			this.db.set(key, val);
			console.log(`LoginDB set key=${key} val=${val} success`);
		} catch (err) {
			console.error(err);
		}
	}

	get(key) {
		try {
			this.db.get(key);
			console.log(`LoginDB get key=${key} returns `)
		} catch (err) {
			console.error(err);
		}
	}
}

module.exports = new LoginDB();