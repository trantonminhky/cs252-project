import EventDB from '../db/EventDB.js';
import UserDB from '../db/UserDB.js';
import ServiceResponse from '../helper/ServiceResponse.js';
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

		const response = new ServiceResponse(
			true,
			201,
			"Success"
		);
		return response;
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
		EventDB.push(eventID, username, "participants");
		const response = new ServiceResponse(
			true,
			200,
			"Success"
		);
		return response;
	}

	async unsubscribe(username, eventID) {
		EventDB.remove(eventID, username, "participants");
		const response = new ServiceResponse(
			true,
			200,
			"Success"
		);
		return response;
	}

	async getByUsername(username) {
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