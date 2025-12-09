import { Router } from 'express';
const router = Router();
import LocationController from '../controllers/LocationController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.all('/import',
	ValidatorMiddleware.validateMethods(['POST']),
	LocationController.importToDB
);

router.all('/search',
	ValidatorMiddleware.validateMethods(['POST']),
	LocationController.search
);

router.all('/:locationID',
	ValidatorMiddleware.validateMethods(['GET']),
	LocationController.getLocation
)

export default router;