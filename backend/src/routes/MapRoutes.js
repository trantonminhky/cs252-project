import { Router } from 'express';
const router = Router();
import mapController from '../controllers/MapController';

// Rouitng
router.post('/route', mapController.getRoute);

// Search
router.get('/search/nearby', mapController.searchNearby);

// Tourism spots
router.get('/tourism-spots', mapController.getTourismSpots);
router.get('/tourism-spots/nearby', mapController.getTourismSpotsNearby);
router.get('/tourism-spots/:id', mapController.getTourismSpotById);

// Static map
router.get('/static-map', mapController.getStaticMap);

export default router;