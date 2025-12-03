import { Router } from 'express';
const router = Router();
import geocodeController from '../controllers/GeocodeController.js';
import validateBearerToken from '../middleware/validateBearerToken.js';

router.get('/geocode', validateBearerToken, geocodeController.geocode);
router.get('/reverse-geocode', validateBearerToken, geocodeController.reverseGeocode);

export default router;