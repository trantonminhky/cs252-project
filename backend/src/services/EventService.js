import EventDB from '../db/EventDB.js';
import UserDB from '../db/UserDB.js';
import ServiceResponse from '../helper/ServiceResponse.js';
import unwrapTyped from '../helper/unwrapTyped.js';

class EventService {
	async createEvent(name, description, imageLink = null, endTime = null) {
		if (!name) {
			const response = new ServiceResponse(
				false,
				400,
				"Evevnt name is required"
			);
			return response;
		}

		if (!description) {
			description = "No description."
		}

		try {
			const eventID = EventDB.autonum();
			const eventData = {
				id: eventID,
				name: name,
				description: description,
				startTime: Date.now(),
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
		} catch (err) {
			const response = new ServiceResponse(
				false,
				500,
				"Something went wrong"
			);
			return response;
		}
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

	async getByUsername(username) {
		if (!username) {
			const response = new ServiceResponse(
				false,
				400,
				"Username is required"
			);
			return response;
		}

		try {
			const parse = JSON.parse(EventDB.export());
			const data = {};
			for (const entry of parse.v.keys.v) {
				data[entry.v.key.v] = unwrapTyped(JSON.parse(entry.v.value.v));
			}

			const results = [];
			for (const [key, val] of Object.entries(data)) {
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
		} catch (err) {
			const response = new ServiceResponse(
				false,
				500,
				"Something went wrong"
			);
			return response;
		}
	}
}

export default new EventService();