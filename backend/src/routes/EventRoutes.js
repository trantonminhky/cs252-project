import { Router } from 'express';
const router = Router();
import EventController from '../controllers/EventController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.all('/import',
	ValidatorMiddleware.validateMethods(['POST']),
	EventController.importToDB
);

router.all('/create',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateContentType, 
	EventController.createEvent
);

router.all('/subscribe',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateContentType, 
	EventController.subscribe
);

router.all('/unsubscribe',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateContentType, 
	EventController.unsubscribe
);

router.all('/get-by-username',
	ValidatorMiddleware.validateMethods(['GET', 'HEAD']),
	EventController.getByUsername
);

export default router;