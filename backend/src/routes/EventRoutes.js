import { Router } from 'express';
const router = Router();
import EventController from '../controllers/EventController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.get('/import', 
	EventController.importToDB
);

router.post('/create', 
	ValidatorMiddleware.validateContentType, 
	EventController.createEvent
);

router.post('/subscribe', 
	ValidatorMiddleware.validateContentType, 
	EventController.subscribe
);

router.post('/unsubscribe', 
	ValidatorMiddleware.validateContentType, 
	EventController.unsubscribe
);

router.get('/get-by-username', 
	EventController.getByUsername
);

export default router;