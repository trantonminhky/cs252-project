const express = require('express');
const router = express.Router();
const LocationController = require('../controllers/LocationController').default;

router.get('/import', LocationController.importToDB);
router.get('/search', LocationController.search);

module.exports = router;