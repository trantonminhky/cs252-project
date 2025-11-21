const fs = require('fs');
const path = require('path');


class DBService {
	constructor() {
		const dir = path.join(__dirname, '..', "db");
		const databases = fs.readdirSync(dir).map(db => require(path.join(dir, db)));
		this.databases = databases;
	}

	async get() {
		const exports = databases.map(db => JSON.parse(db.export()));
		return exports
	}
}