import { Router } from 'express';
const router = Router();
import geocodeController from '../controllers/GeocodeController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.all('/geocode',
	ValidatorMiddleware.validateMethods(['GET', 'HEAD']),
	ValidatorMiddleware.validateSessionToken,
	geocodeController.geocode
);

router.all('/reverse-geocode',
	ValidatorMiddleware.validateMethods(['GET', 'HEAD']),
	ValidatorMiddleware.validateSessionToken,
	geocodeController.reverseGeocode
);

export default router;