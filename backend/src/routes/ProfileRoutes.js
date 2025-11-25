const express = require('express');
const router = express.Router();
const profileController = require('../controllers/ProfileController');

router.post('/register', profileController.register);
router.get('/login', profileController.login);

module.exports = router;