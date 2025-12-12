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
	 * Service function for <code>api/db/clear</code>. Clears a database given the name. <b>This action is irreversible</b>. Supports <code>DELETE</code> requests.
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
	 * Service function for <code>api/db/clear-all</code>. Clears alls data from all databases. <b>This action is destructive and irreversible</b>. Supports <code>DELETE</code> requests.
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
	 * Service function for <code>api/db/export</code>. Export Enmap database to readable JSON given database name. Supports <code>GET</code> requests.
	 * @param {String} name - Database name
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl http://localhost:3000/api/db/export?name=UserDB
	 * 
	 * @example <caption>Response</caption>
	 * {
	 *	"success": true,
	 *	"statusCode": 200,
	 *	"payload": {
	 *		"message": "Success (OK)",
	 *		"data": {
	 *			"d5e098a7-fc92-41c2-916b-f1e0f58bcdf7": {
	 * 				"username": "aoanoavn",
	 * 				"discriminant": "4737",
	 * 				"email": "rete@gmail.com",
	 * 				"password": "$2b$10$3SGnzOZ9uHwkNkttyBBA6ebQgYtVzY0zv7vvhKBH1Pua3cnwKXM6S",
	 * 				"name": "1oj2n4o2",
	 * 				"age": 12,
	 * 				"preferences": [],
	 * 				"preferencesVector": null,
	 * 				"type": "business",
	 * 				"savePlaces": []
	 * 			}
	 * 		}
	 * 	}
	 * }
	 * 
	 * @property {OK} 200 - Successful request
	 * @property {BAD_REQUEST} 400 - Missing name
	 * @property {NOT_FOUND} 404 - Database name is not found
	 * @property {METHOD_NOT_ALLOWED} 405 - The endpoint does not support the HTTP method specified
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
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
	 * Service function for <code>/api/db/export-all</code>. Get the whole Enmap databases exported and formatted as a readable JSON. Supports <code>GET</code> requests.
	 * @returns {Promise<ServiceResponse>} Response
	 * 
	 * @example <caption>cURL</caption>
	 * curl http://localhost:3000/api/db/export-all
	 * 
	 * @example <caption>Response</caption>
	 * {
	 * 	"success": true,
	 * 	"statusCode": 200,
	 * 	"payload": {
	 * 		"message": "Success (OK)",
	 * 		"data": {
	 * 			"CacheDB": { ... },
	 * 			"EventDB": { ... },
	 * 			"LocationDB": { ... },
	 * 			"UserDB": { ... }
	 * 		}		
	 * 	}
	 * }
	 * 
	 * @property {OK} 200 - Successful request
	 * @property {METHOD_NOT_ALLOWED} 405 - The endpoint does not support the HTTP method specified
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
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