const express = require('express');
const router = express.Router();
const profileController = require('../controllers/ProfileController');

router.post('/register', profileController.register);
router.post('/login', profileController.login);

module.exports = router;