const express = require('express');
const router = express.Router();
const LocationController = require('../controllers/LocationController');

router.get('/import', LocationController.importToDB);

module.exports = router;