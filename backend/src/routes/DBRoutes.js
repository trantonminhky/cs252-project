const express = require('express');
const router = express.Router();
const DBController = require('../controllers/DBController');

router.get('/dangerous/get', DBController.get);

module.exports = router;