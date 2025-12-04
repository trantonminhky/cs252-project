import { Router } from 'express';
const router = Router();
import DBController from '../controllers/DBController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.all('/clear',
	ValidatorMiddleware.validateMethods(['DELETE']),
	DBController.clear
);

router.all('/clear-all',
	ValidatorMiddleware.validateMethods(['DELETE']),
	DBController.clearAll
);

router.all('/export',
	ValidatorMiddleware.validateMethods(['GET', 'HEAD']),
	DBController.export
);

router.all('/export-all',
	ValidatorMiddleware.validateMethods(['GET', 'HEAD']),
	DBController.exportAll
);

export default router;