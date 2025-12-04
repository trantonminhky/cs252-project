import { readdirSync } from 'fs';
import path from 'path';
import { fileURLToPath, pathToFileURL } from 'url';
import ServiceResponse from '../helper/ServiceResponse.js';
import unwrapTyped from '../helper/unwrapTyped.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Representation of databases. Note that THIS OBJECT IS ONLY FOR VIEWING PURPOSE, REFRAIN FROM DIRECTLY MODIFYING VIA THIS INFERFACE.
 * @class
 */
class DBService {
	constructor() {
		const dir = path.join(__dirname, '..', "db");
		this.databases = Promise.all(
			readdirSync(dir).map(async file => {
				const filePath = path.join(dir, file);
				const fileUrl = pathToFileURL(filePath).href;
				const mod = await import(fileUrl);
				return mod.default ?? mod;
			})
		);
	}

	/**
	 * Clear selected database given name. This action is destructive and irreparable.
	 * @param {name} name - Database name
	 * @returns {Promise<ServiceResponse>}
	 */
	async clear(name) {
		const databases = await this.databases;

		for (const db of databases) {
			const parse = JSON.parse(db.export());
			if (parse.v.name.v == name) {
				db.clear();
				return (new ServiceResponse(
					true,
					204,
					"Success"
				));
			}
		}

		return (new ServiceResponse(
			false,
			404,
			"No database with such name is found"
		));
	}

	/**
	 * Clear all databases. This action is destructive and irreparable.
	 * @returns {Promise<ServiceResponse>}
	 */
	async clearAll() {
		const databases = await this.databases;
		databases.forEach(db => db.clear());
		return (new ServiceResponse(
			true,
			204,
			"Success"
		));
	}

	/**
	 * Export Enmap database to readable JSON given database name
	 * @param {String} name - Database name
	 * @returns {Promise<ServiceResponse>} - Response
	 */
	async export(name) {
		const databases = await this.databases;

		for (const db of databases) {
			const _export = db.export();
			if (_export.name === name) {
				return (new ServiceResponse(
					true,
					200,
					"Success",
					_export.data
				));
			}
		}

		return (new ServiceResponse(
			false,
			404,
			"No database with such name is found"
		));
	}

	/**
	 * Get the Enmap exported and formatted as a readable JSON
	 * @returns {Promise<ServiceResponse>} Response
	 */
	async exportAll() {
		const databases = await this.databases;
		
		const exports = {};
		for (const db of databases) {
			const parse = JSON.parse(db.export());
			const name = parse.v.name.v;
			const data = {};
			for (const entry of parse.v.keys.v) {
				data[entry.v.key.v] = unwrapTyped(JSON.parse(entry.v.value.v));
			}
			exports[name] = data;
		}

		if (Object.keys(exports).length === 0) {
			return (new ServiceResponse(
				true,
				204,
				"Success, databases empty",
				exports
			));
		} else {
			return (new ServiceResponse(
				true,
				200,
				"Success",
				exports
			));
		}
	}
}

export default new DBService();