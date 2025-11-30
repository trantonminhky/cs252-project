const express = require('express');
const router = express.Router();
const geocodeController = require('../controllers/GeocodeController').default;

router.get('/geocode', geocodeController.geocode);
router.get('/reverse-geocode', geocodeController.reverseGeocode);

module.exports = router;