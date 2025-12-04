import { Router } from 'express';
const router = Router();
import profileController from '../controllers/ProfileController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.post('/register',
	ValidatorMiddleware.validateContentType,
	profileController.register
);

router.post('/login',
	ValidatorMiddleware.validateContentType,
	profileController.login
);

router.post('/preferences',
	ValidatorMiddleware.validateContentType,
	profileController.setPreferences
);

router.get('/saved-places',
	profileController.getSavedPlaces
);

router.post('/saved-places',
	ValidatorMiddleware.validateContentType,
	profileController.addSavedPlace
);

router.delete('/saved-places',
	profileController.removeSavedPlace
);

export default router;