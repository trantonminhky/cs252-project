import { Router } from 'express';
const router = Router();
import mapController from '../controllers/MapController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.post('/route',
	ValidatorMiddleware.validateSessionToken, 
	ValidatorMiddleware.validateContentType, 
	mapController.getRoute
);

router.get('/nearby',
	ValidatorMiddleware.validateSessionToken, 
	mapController.nearby
);


export default router;