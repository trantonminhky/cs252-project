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

import Enmap from 'enmap';
import unwrapTyped from '../helper/unwrapTyped.js';

class EventDB {
	constructor() {
		this.db = new Enmap({ name: 'EventDB' });
	}

	// autonum is used to ensure non-duplicate id
	autonum() {
		return this.db.autonum;
	}

	set(key, val, path) {
		try {
			this.db.set(key, val, path);
		} catch (err) {
			console.error(err);
		}
	}

	get(key, path) {
		try {
			const value = this.db.get(key, path);
			return value;
		} catch (err) {
			console.error(err);
		}
	}

	delete(key, path) {
		try {
			this.db.delete(key, path);
		} catch (err) {
			console.error(err);
		}
	}

	remove(key, value, path) {
		try {
			this.db.remove(key, value, path);
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

	push(key, value, path, allowDupes = false) {
		try {
			this.db.push(key, value, path, allowDupes);
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
}

export default new EventDB();