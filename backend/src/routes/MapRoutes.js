import { Router } from 'express';
const router = Router();
import mapController from '../controllers/MapController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.all('/route',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateAccessToken, 
	ValidatorMiddleware.validateContentType, 
	mapController.getRoute
);

router.all('/nearby',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateAccessToken, 
	mapController.nearby
);


export default router;