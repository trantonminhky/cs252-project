const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');

router.post('/register', profileController.register);
router.get('/login', profileController.login);

router.get('/dangerous/clear', profileController.clear);

module.exports = router;