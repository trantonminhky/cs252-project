const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');

router.get('/test', profileController.test);

module.exports = router;