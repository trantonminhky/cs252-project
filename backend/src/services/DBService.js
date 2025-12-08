import { readdirSync } from 'fs';
import path from 'path';
import { fileURLToPath, pathToFileURL } from 'url';
import ServiceResponse from '../helper/ServiceResponse.js';

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
	 * Service function for <b>api/db/clear</b>. Clears a database given the name. <b>This action is irreversible</b>. Supports <b>DELETE</b> requests.
	 * @param {name} name - Database name to delete
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl -X DELETE http://localhost:3000/api/db/clear?name=CacheDB
	 * 
	 * @property {NO_CONTENT} 204 - Successful request
	 * @property {BAD_REQUEST} 400 - Missing name
	 * @property {NOT_FOUND} 404 - No database with the given name is found
	 * @property {METHOD_NOT_ALLOWED} 405 - The endpoint does not support the HTTP method specified
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
	 */

	async clear(name) {
		const databases = await this.databases;

		for (const db of databases) {
			const _export = db.export();

			if (_export.name === name) {
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
	 * Service function for <b>api/db/clear-all</b>. Clears alls data from all databases. <b>This action is destructive and irreversible</b>. Supports <b>DELETE</b> requests.
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl -X DELETE http://localhost:3000/api/db/clear-all
	 * 
	 * @property {NO_CONTENT} 204 - Successful request
	 * @property {METHOD_NOT_ALLOWED} 405 - The endpoint does not support the HTTP method specified
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
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
			const _export = db.export();
			exports[_export.name] = _export.data;
		}

		return (new ServiceResponse(
			true,
			200,
			"Success",
			exports
		));
	}
}

export default new DBService();