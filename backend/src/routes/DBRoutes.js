const express = require('express');
const router = express.Router();
const DBController = require('../controllers/DBController').default;

router.delete('/clear', DBController.clear);
router.delete('/clear-all', DBController.clearAll);
router.get('/export', DBController.export);
router.get('/export-all', DBController.exportAll);

module.exports = router;