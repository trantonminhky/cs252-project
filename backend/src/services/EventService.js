import EventDB from '../db/EventDB.js';
import UserDB from '../db/UserDB.js';
import ServiceResponse from '../helper/ServiceResponse.js';
import unwrapTyped from '../helper/unwrapTyped.js';
import eventsData from '../../events.json' with { type: "json" };

class EventService {
	async importToDB() {
		for (const entry of eventsData) {
			const eventID = EventDB.autonum();
			EventDB.set(eventID, {
				id: eventID,
				name: entry.name_translated,
				description: entry.description_translated,
				startTime: entry.s_milliseconds,
				endTime: entry.e_milliseconds,
				imageLink: entry.image_link,
				participants: []
			});
		}
	}

	async createEvent(name, description, imageLink = null, startTime = null, endTime = null) {
		const eventID = EventDB.autonum();
		const eventData = {
			id: eventID,
			name: name,
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
			eventData
		);
		return response;
	}

	async subscribe(username, eventID) {
		if (!username) {
			const response = new ServiceResponse(
				false,
				400,
				"Username is required"
			);
			return response;
		}

		if (!eventID) {
			const response = new ServiceResponse(
				false,
				400,
				"Event ID is required"
			);
			return response;
		}

		if (!UserDB.has(username)) {
			const response = new ServiceResponse(
				false,
				404,
				"Username not found"
			);
			return response;
		}

		if (!EventDB.has(eventID)) {
			const response = new ServiceResponse(
				false,
				404,
				"Event not found"
			);
			return response;
		}

		EventDB.push(eventID, username, "participants");
		const response = new ServiceResponse(
			true,
			200,
			"Success"
		);
		return response;
	}

	async unsubscribe(username, eventID) {
		if (!username) {
			const response = new ServiceResponse(
				false,
				400,
				"Username is required"
			);
			return response;
		}

		if (!eventID) {
			const response = new ServiceResponse(
				false,
				400,
				"Event ID is required"
			);
			return response;
		}

		if (!UserDB.has(username)) {
			const response = new ServiceResponse(
				false,
				404,
				"Username not found"
			);
			return response;
		}

		if (!EventDB.has(eventID)) {
			const response = new ServiceResponse(
				false,
				404,
				"Event not found"
			);
			return response;
		}

		EventDB.remove(eventID, username, "participants");
		const response = new ServiceResponse(
			true,
			200,
			"Success"
		);
		return response;
	}

	async getByUsername(username) {
		if (!username) {
			const response = new ServiceResponse(
				false,
				400,
				"Username is required"
			);
			return response;
		}

		const _export = EventDB.export();

		const results = [];
		for (const [key, val] of Object.entries(_export)) {
			if (val.participants.includes(username)) {
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