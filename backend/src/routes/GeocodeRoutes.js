import { Router } from 'express';
const router = Router();
import geocodeController from '../controllers/GeocodeController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.get('/geocode',
	ValidatorMiddleware.validateBearerToken,
	geocodeController.geocode
);

router.get('/reverse-geocode',
	ValidatorMiddleware.validateBearerToken,
	geocodeController.reverseGeocode
);

export default router;