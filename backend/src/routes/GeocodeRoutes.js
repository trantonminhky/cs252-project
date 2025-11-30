import { Router } from 'express';
const router = Router();
import geocodeController from '../controllers/GeocodeController';

router.get('/geocode', geocodeController.geocode);
router.get('/reverse-geocode', geocodeController.reverseGeocode);

export default router;