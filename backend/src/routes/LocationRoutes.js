import { Router } from 'express';
const router = Router();
import LocationController from '../controllers/LocationController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

import multer from 'multer';
const upload = multer({ storage: multer.memoryStorage() });

router.all('/import',
	ValidatorMiddleware.validateMethods(['POST']),
	LocationController.importToDB
);

router.all('/search-by-image', upload.single('file'),
	ValidatorMiddleware.validateMethods(['POST']),
	LocationController.searchByImage
)

router.all('/search',
	ValidatorMiddleware.validateMethods(['POST']),
	LocationController.search
);

router.all('/:locationID',
	ValidatorMiddleware.validateMethods(['GET']),
	LocationController.getLocation
)

export default router;