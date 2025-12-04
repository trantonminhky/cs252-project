import { Router } from 'express';
const router = Router();
import LocationController from '../controllers/LocationController.js';

router.get('/import',
	LocationController.importToDB
);

router.get('/search',
	LocationController.search
);

router.get('/find-by-id',
	LocationController.findByID
)

export default router;