const express = require('express');
const router = express.Router();
const profileController = require('../controllers/ProfileController');

router.post('/register', profileController.register);
router.post('/login', profileController.login);
router.post('/preferences', profileController.setPreferences);
module.exports = router;