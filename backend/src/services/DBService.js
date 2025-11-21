const fs = require('fs');
const path = require('path');

function unwrapTyped(x) {
	if (Array.isArray(x)) return x.map(unwrapTyped);

	if (x && typeof x === "object") {
		const keys = Object.keys(x);
		if (keys.length === 2 && keys.includes("t") && keys.includes("v")) {
			return unwrapTyped(x.v);
		}
		const out = {};
		for (const k of keys) out[k] = unwrapTyped(x[k]);
		return out;
	}

	return x;
}

class DBService {
	constructor() {
		const dir = path.join(__dirname, '..', "db");
		const databases = fs.readdirSync(dir).map(db => require(path.join(dir, db)));
		this.databases = databases;
	}

	async get() {
		const exports = this.databases.map(db => {
			const parse = JSON.parse(db.export());
			const data = {};
			for (const entry of parse.v.keys.v) {
				data[entry.v.key.v] = unwrapTyped(JSON.parse(entry.v.value.v));
				console.log(entry.v);
			}
			return data;
		});
		return exports;
	}
}

module.exports = new DBService();