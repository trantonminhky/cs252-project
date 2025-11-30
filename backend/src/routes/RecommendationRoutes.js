const express = require('express');
const router = express.Router();
const recController = require('../controllers/RecommendationController');

router.get('/', recController.getRecommendations);
router.post('/feedback', recController.sendFeedback);

module.exports = router;