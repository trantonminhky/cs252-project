/*
	"0": {
		id: "0",
		name: "Great Event of Lorem Ipsum",
		description: "Lorem ipsum dolor sit amet",
		startTime: 123456789,
		endTime: null,
		imageLink: "https://example.com",
		participants: ["miku", "teto"]
	}, ...
*/

class EventDB {
	constructor() {
		import('enmap').then(async ({ default: Enmap }) => {
			this.db = new Enmap({ name: 'EventDB' });
		});
	}

	// autonum is used to ensure non-duplicate id
	autonum() {
		return this.db.autonum;
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

	has(key) {
		try {
			return this.db.has(key);
		} catch (err) {
			console.error(err);
		}
	}

	push(key, value, path, allowDupes=false) {
		try {
			this.db.push(key, value, path, allowDupes);
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

export default new EventDB();