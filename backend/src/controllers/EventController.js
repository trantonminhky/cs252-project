import ServiceResponse from '../helper/ServiceResponse.js';
import EventService from '../services/EventService.js'

class EventController {
	async createEvent(req, res, next) {
		try {
			const name = req.body.name;
			const description = req.body.description;
			const imageLink = req.body.imageLink;
			const endTime = req.body.endTime;

			if (!name) {
				const response = new ServiceResponse(
					false,
					400,
					"Event name is required"
				);
				return void res.status(response.statusCode).json(response.get());
			}
			
			const response = await EventService.createEvent(name, description, imageLink, endTime);
			return void res.status(response.statusCode).json(response.get());
		} catch (err) {
			next(err);
		}
	}
}

export default new EventController();