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

/**
 * Representation of databases. Note that THIS OBJECT IS ONLY FOR VIEWING PURPOSE, REFRAIN FROM DIRECTLY MODIFYING VIA THIS INFERFACE.
 * @class
 */
class DBService {
	constructor() {
		const dir = path.join(__dirname, '..', "db");
		const databases = fs.readdirSync(dir).map(db => require(path.join(dir, db)));
		this.databases = databases;
	}

	async export() {

	}

	/**
	 * Get the Enmap exported and formatted as a readable JSON
	 * @returns {Object} Exported database
	 */
	async exportAll() {
		const exports = {};
		for (const db of this.databases) {
			const parse = JSON.parse(db.export());
			const name = parse.v.name.v;
			const data = {};
			for (const entry of parse.v.keys.v) {
				data[entry.v.key.v] = unwrapTyped(JSON.parse(entry.v.value.v));
			}
			exports[name] = data;
		}
		return exports;
	}
}

module.exports = new DBService();