import { Router } from 'express';
const router = Router();
import EventController from '../controllers/EventController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.all('/import',
	ValidatorMiddleware.validateMethods(['POST']),
	EventController.importToDB
);

router.all('/',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateContentType,
	EventController.createEvent
);

router.all('/get-by-userid',
	ValidatorMiddleware.validateMethods(['GET', 'HEAD']),
	EventController.getByUserID
);

router.all('/:eventID',
	ValidatorMiddleware.validateMethods(['GET']),
	EventController.getEvent
);

router.all('/:eventID/participants/:userID',
	ValidatorMiddleware.validateMethods(['PUT', 'DELETE']), async (req, res, next) => {
		if (req.method === 'PUT') {
			await EventController.subscribe(req, res, next);
		} else if (req.method === 'DELETE') {
			await EventController.unsubscribe(req, res, next);
		}
	}
)

export default router;