import EventDB from '../db/EventDB.js';
import ServiceResponse from '../helper/ServiceResponse.js';

class EventService {
	async createEvent(name, description, imageLink=null, endTime=null) {
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
}

export default new EventService();