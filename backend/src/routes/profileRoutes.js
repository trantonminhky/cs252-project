const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');

router.post('/test-set', profileController.test_set);
router.get('/test-get', profileController.test_get);

module.exports = router;