const express = require('express');
const router = express.Router();
const AIController = require('../controllers/AIController').default;

// AI ask endpoint
router.post('/send-prompt', AIController.sendPrompt);
router.get('/extract-tags', AIController.extractTags);

module.exports = router;