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
	ValidatorMiddleware.validateMethods(['GET', 'POST', 'DELETE', 'HEAD']),
	(req, res, next) => {
		// Only validate Content-Type for POST and DELETE
		if (req.method === 'POST' || req.method === 'DELETE') {
			return ValidatorMiddleware.validateContentType(req, res, next);
		}
		next();
	},
	profileController.savedPlacesController
);

router.all('/:userID',
	ValidatorMiddleware.validateMethods(['GET', 'HEAD']),
	profileController.getUser	
);

export default router;