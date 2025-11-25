const express = require('express');
const router = express.Router();
const AIController = require('../controllers/AIController');

// AI ask endpoint
router.post('/send-prompt', AIController.sendPrompt);

module.exports = router;