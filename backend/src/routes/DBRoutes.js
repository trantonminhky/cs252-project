import { Router } from 'express';
const router = Router();
import DBController from '../controllers/DBController.js';

router.delete('/clear',
	DBController.clear
);

router.delete('/clear-all',
	DBController.clearAll
);

router.get('/export',
	DBController.export
);

router.get('/export-all',
	DBController.exportAll
);

export default router;