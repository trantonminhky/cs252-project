import { Router } from 'express';
const router = Router();
import LocationController from '../controllers/LocationController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.all('/import',
	ValidatorMiddleware.validateMethods(['GET']),
	LocationController.importToDB
);

router.all('/search',
	ValidatorMiddleware.validateMethods(['GET']),
	LocationController.search
);

router.all('/find-by-id',
	ValidatorMiddleware.validateMethods(['GET']),
	LocationController.findByID
)

export default router;