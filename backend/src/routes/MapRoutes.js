const express = require('express');
const router = express.Router();
const mapController = require('../controllers/MapController').default;

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

module.exports = router;