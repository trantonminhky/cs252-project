import EventDB from '../db/EventDB.js';
import ServiceResponse from '../helper/ServiceResponse.js';
import eventsData from '../../events.json' with { type: "json" };

// TO-DO: ADD LOCATION TO EVENT

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