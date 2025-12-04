import ServiceResponse from '../helper/ServiceResponse.js';
import EventService from '../services/EventService.js'

class EventController {
	async importToDB(req, res, next) {
		await EventService.importToDB();
		return void res.status(200).json("lol");
	}

	async createEvent(req, res, next) {
		try {
			const name = req.body.name;
			const description = req.body.description;
			const imageLink = req.body.imageLink;
			const startTime = req.body.startTime;
			const endTime = req.body.endTime;

			if (!name) {
				const response = new ServiceResponse(
					false,
					400,
					"Event name is required"
				);
				return void res.status(response.statusCode).json(response.get());
			}

			if (!description) {
				description = "No description.";
			}

			const response = await EventService.createEvent(name, description, imageLink, startTime, endTime);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async subscribe(req, res, next) {
		try {
			const username = req.body.username;
			const eventID = req.body.eventID;

			const response = await EventService.subscribe(username, eventID);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async unsubscribe(req, res, next) {
		try {
			const username = req.body.username;
			const eventID = req.body.eventID;

			const response = await EventService.unsubscribe(username, eventID);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async getByUsername(req, res, next) {
		try {
			const { username } = req.query;
			const response = await EventService.getByUsername(username);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new EventController();