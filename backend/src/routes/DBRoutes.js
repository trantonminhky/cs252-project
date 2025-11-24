const express = require('express');
const router = express.Router();
const DBController = require('../controllers/DBController');

router.get('/exportAll', DBController.exportAll);

module.exports = router;