import { Router } from 'express';
const router = Router();
import profileController from '../controllers/ProfileController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.all('/register',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateContentType,
	profileController.register
);

router.all('/login',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateContentType,
	profileController.login
);

router.all('/refresh',
	ValidatorMiddleware.validateMethods(['POST']),
	profileController.refresh
);

router.all('/preferences',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateContentType,
	profileController.setPreferences
);

router.all('/saved-places',
	ValidatorMiddleware.validateMethods(['GET,', 'POST', 'DELETE', 'HEAD']),
	profileController.getSavedPlaces
);

export default router;