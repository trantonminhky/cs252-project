const express = require('express');
const router = express.Router();
const DBController = require('../controllers/DBController');

router.get('/clear', DBController.clear);
router.get('/clearAll', DBController.clearAll);
router.get('/export', DBController.export);
router.get('/exportAll', DBController.exportAll);

module.exports = router;