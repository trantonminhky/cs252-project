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
			const location = req.body.location;
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

			if (!location) {
				const response = new ServiceResponse(
					false,
					400,
					'Event location is required'
				);
				return void res.status(response.statusCode).json(response.get());
			}

			const response = await EventService.createEvent(name, description, imageLink, startTime, endTime);

			if (response.success) res.set("Location", `/api/event/${response.payload.data.eventID}`);

			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async getEvent(req, res, next) {
		try {
			const eventID = req.params.eventID;
	
			if (eventID === ':eventID') {
				const response = new ServiceResponse(
					false,
					404,
					"Route not found"
				);
	
				return void res.status(response.statusCode).json(response.get());
			}
	
			const response = await EventService.getEvent(eventID);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}

	async subscribe(req, res, next) {
		try {
			const userID = req.params.userID;
			const eventID = req.params.eventID;

			console.log(`userID ${userID}`);
			console.log(`eventID ${eventID}`);

			if (userID === ':userID') {
				const response = new ServiceResponse(
					false,
					404,
					"Route not found"
				);

				return void res.status(response.statusCode).json(response.get());;
			}

			if (eventID === ':eventID') {
				const response = new ServiceResponse(
					false,
					404,
					"Route not found"
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