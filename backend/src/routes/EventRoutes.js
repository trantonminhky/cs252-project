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

router.all('/:eventID',
	ValidatorMiddleware.validateMethods(['GET']),
	EventController.getEvent
);

router.all('/:eventID/participants/:userID',
	ValidatorMiddleware.validateMethods(['PUT']),
	EventController.subscribe
)

router.all('/unsubscribe',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateContentType, 
	EventController.unsubscribe
);

router.all('/get-by-userid',
	ValidatorMiddleware.validateMethods(['GET', 'HEAD']),
	EventController.getByUserID
);

export default router;