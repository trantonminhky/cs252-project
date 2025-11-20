const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');

router.get('/test-set', profileController.test_set);

module.exports = router;