const express = require('express');
const router = express.Router();
const AIController = require('../controllers/AIController');

// AI ask endpoint
router.get('/ask', AIController.ask);

module.exports = router;