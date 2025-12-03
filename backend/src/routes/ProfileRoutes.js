import { Router } from 'express';
const router = Router();
import profileController from '../controllers/ProfileController.js';
import validateContentType from '../middleware/validateContentType.js';

router.post('/register', validateContentType, profileController.register);
router.post('/login', validateContentType, profileController.login);
router.post('/preferences', validateContentType, profileController.setPreferences);

router.get('/saved-places', profileController.getSavedPlaces);     // Fetch list
router.post('/saved-places', validateContentType, profileController.addSavedPlace);     // Add item
router.delete('/saved-places', profileController.removeSavedPlace); // Remove item  
export default router;""
