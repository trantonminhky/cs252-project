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
	ValidatorMiddleware.validateMethods(['GET', 'POST', 'DELETE']),
	(req, res, next) => {
		// Only validate Content-Type for POST and DELETE
		if (req.method === 'POST' || req.method === 'DELETE') {
			return ValidatorMiddleware.validateContentType(req, res, next);
		}
		next();
	}, async (req, res, next) => {
		if (req.method === 'GET') {
			await profileController.getSavedPlaces(req, res, next);
		} else if (req.method === 'POST') {
			await profileController.addSavedPlace(req, res, next);
		} else if (req.method === 'DELETE') {
			await profileController.removeSavedPlace(req, res, next);
		}
	}
);

router.all('/:userID',
	ValidatorMiddleware.validateMethods(['GET', 'HEAD']),
	profileController.getUser	
);

export default router;