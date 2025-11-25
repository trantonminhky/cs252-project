const express = require('express');
const router = express.Router();
const DBController = require('../controllers/DBController');

router.delete('/clear', DBController.clear);
router.delete('/clearAll', DBController.clearAll);
router.get('/export', DBController.export);
router.get('/exportAll', DBController.exportAll);

module.exports = router;