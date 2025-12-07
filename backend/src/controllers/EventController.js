import ServiceResponse from '../helper/ServiceResponse.js';
import EventService from '../services/EventService.js'
import UserDB from '../db/UserDB.js';
import EventDB from '../db/EventDB.js';

class EventController {
	async importToDB(req, res, next) {
		try {
			const response = await EventService.importToDB();
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
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
			const userID = req.body.userID;
			const eventID = req.body.eventID;

			if (!userID) {
				const response = new ServiceResponse(
					false,
					400,
					"User ID is required"
				);
				
				return void res.status(response.statusCode).json(response.get());;
			}

			if (!eventID) {
				const response = new ServiceResponse(
					false,
					400,
					"Event ID is required"
				);
				
				return void res.status(response.statusCode).json(response.get());;
			}

			if (!UserDB.has(userID)) {
				const response = new ServiceResponse(
					false,
					404,
					"User not found"
				);
				
				return void res.status(response.statusCode).json(response.get());;
			}

			if (!EventDB.has(eventID)) {
				const response = new ServiceResponse(
					false,
					404,
					"Event not found"
				);
				
				return void res.status(response.statusCode).json(response.get());;
			}

			const response = await EventService.subscribe(userID, eventID);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async unsubscribe(req, res, next) {
		try {
			const userID = req.body.userID;
			const eventID = req.body.eventID;

			if (!userID) {
				const response = new ServiceResponse(
					false,
					400,
					"User ID is required"
				);
				
				return void res.status(response.statusCode).json(response.get());;
			}

			if (!eventID) {
				const response = new ServiceResponse(
					false,
					400,
					"Event ID is required"
				);
				
				return void res.status(response.statusCode).json(response.get());;
			}

			if (!UserDB.has(userID)) {
				const response = new ServiceResponse(
					false,
					404,
					"User ID not found"
				);
				
				return void res.status(response.statusCode).json(response.get());;
			}

			if (!EventDB.has(eventID)) {
				const response = new ServiceResponse(
					false,
					404,
					"Event not found"
				);
				
				return void res.status(response.statusCode).json(response.get());;
			}

			const response = await EventService.unsubscribe(userID, eventID);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async getByUserID(req, res, next) {
		try {
			const userID = req.query.userID;

			if (!userID) {
				const response = new ServiceResponse(
					false,
					400,
					"User ID is required"
				);
				
				return void res.status(response.statusCode).json(response.get());;
			}

			const response = await EventService.getByUserID(userID);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new EventController();