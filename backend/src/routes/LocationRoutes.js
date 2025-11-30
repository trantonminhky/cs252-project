const express = require('express');
const router = express.Router();
const LocationController = require('../controllers/LocationController');

router.get('/import', LocationController.importToDB);
router.get('/search', LocationController.search);

module.exports = router;