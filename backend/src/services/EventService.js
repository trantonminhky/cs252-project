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
	 * Service function for <code>/api/event/create</code>. Creates an event whose data is indicated by the URI located in the <code>Location</code> header. Supports <code>POST</code> requests.
	 * @param {String} name - Event's name
	 * @param {String} locationID - Event's location (TO-DO: VERIFY LOCATION UUID)
	 * @param {String} [description='No description.'] - Event's description
	 * @param {String} [imageLink] - Event's image
	 * @param {Number} [startTime=Date.now()] - Event's start date. The input should be the number of milliseconds elapsed from the Unix epoch (00:00:00 UTC January 1st 1970)
	 * @param {Number} [endTime=Infinity] - Event's end date. The input should be the number of milliseconds elapsed from the Unix epoch (00:00:00 UTC January 1st 1970).
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl -X POST \
	 * --header 'Content-Type:application/json' \
	 * --data '{"name":"Hatsune Miku Concert","location":"a-really-cool-uuid", "description":"insanely greate!!!!!11111!!11one"}' \
	 * http://localhost:3000/api/event
	 * 
	 * @property {CREATED} 201 - Successful request
	 * @property {BAD_REQUEST} 400 - Missing name or location ID
	 */
	async createEvent(name, description = 'No description.', locationID, imageLink = null, startTime = Date.now(), endTime = Infinity) {
		const eventID = randomUUID();
		const eventData = {
			name: name,
			location: locationID,
			description: description,
			startTime: startTime,
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

	/**
	 * Service function for <code>/api/event/:eventID</code>. Gets event's data given its UUID. Supports <code>GET</code> requests.
	 * @param {String} eventID - Event's ID
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl http://localhost:3000/api/event/3378ce57-2118-471a-8ebf-85c29fb06ca7
	 * 
	 * @example <caption>Response</caption>
	 * {
	 * 	"success": true,
	 * 	"statusCode": 200,
	 * 	"payload": {
	 * 		"message": "Success (OK)",
	 * 		"data": {
	 * 			"name": "Hatsune Miku Concert",
	 * 			"description": "insanely greate!!!!!11111!!11one",
	 * 			"startTime": 1765264904268,
	 * 			"endTime": null,
	 * 			"imageLink": null,
	 * 			"participants": []
	 * 		}
	 * 	}
	 * }
	 * 
	 * @property {OK} 200 - Successful request
	 * @property {NOT_FOUND} 404 - Event ID was not specified, or event does not exist
	 * @property {METHOD_NOT_ALLOWED} 405 - The endpoint does not support the HTTP method specified
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
	 */
	async getEvent(eventID) {
		if (!EventDB.has(eventID)) {
			const response = new ServiceResponse(
				false,
				404,
				"Event not found"
			);
			
			return response;
		}

		const data = EventDB.get(eventID);
		const response = new ServiceResponse(
			true,
			200,
			"Success",
			data
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