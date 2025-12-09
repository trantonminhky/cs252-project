import EventDB from '../db/EventDB.js';
import ServiceResponse from '../helper/ServiceResponse.js';
import eventsData from '../../events.json' with { type: "json" };

import { randomUUID } from "crypto";

// TO-DO: ADD LOCATION TO EVENT
// TO-DO: REST-IFY EVENT AND OVERALL REFACTOR

/**
 * Event service provider class.
 * @class
 */
class EventService {
	/**
	 * Service function for <code>/api/event/import</code>. Import a list of events into database given a JSON. The description is meant to stay vague since this is a developer endpoint. Supports <code>POST</code> requests.
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl -X POST http://localhost:3000/api/event/import
	 * 
	 * @example <caption>Response</caption>
	 * {
	 * 	"success": true,
	 * 	"statusCode": 200,
	 * 	"payload": {
	 * 		"message": "Success (OK)",
	 * 		"data": null
	 * 	}
	 * }
	 * 
	 * @property {CREATED} 201 - Successful request
	 * @property {METHOD_NOT_ALLOWED} 405 - The endpoint does not support the HTTP method specified
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
	 */

	async importToDB() {
		for (const entry of eventsData) {
			const eventID = randomUUID();
			EventDB.set(eventID, {
				id: eventID,
				name: entry.name_translated,
				description: entry.description_translated,
				location: entry.location,
				startTime: entry.s_milliseconds,
				endTime: entry.e_milliseconds,
				imageLink: entry.image_link,
				participants: []
			});
		}

		const response = new ServiceResponse(
			true,
			201,
			"Success"
		);
		return response;
	}

	/**
	 * Service function for <code>/api/event/create</code>
	 */
	async createEvent(name, description, location, imageLink = null, startTime = null, endTime = null) {
		const eventID = randomUUID();
		const eventData = {
			name: name,
			location: location,
			description: description,
			startTime: startTime || Date.now(),
			endTime: endTime,
			imageLink: imageLink,
			participants: []
		}

		EventDB.set(eventID, eventData);

		const response = new ServiceResponse(
			true,
			201,
			"Success",
			{
				eventID: eventID
			}
		);
		return response;
	}

	async subscribe(userID, eventID) {
		EventDB.push(eventID, userID, "participants");
		const response = new ServiceResponse(
			true,
			200,
			"Success"
		);
		return response;
	}

	async unsubscribe(userID, eventID) {
		EventDB.remove(eventID, userID, "participants");
		const response = new ServiceResponse(
			true,
			200,
			"Success"
		);
		return response;
	}

	async getByUserID(userID) {
		const _export = EventDB.export();

		const results = [];
		for (const [key, val] of Object.entries(_export)) {
			if (val.participants.includes(userID)) {
				results.push(val);
			}
		}

		const response = new ServiceResponse(
			true,
			200,
			"Success",
			results
		);
		return response;
	}
}

export default new EventService();