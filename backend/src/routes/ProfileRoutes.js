import { Router } from 'express';
const router = Router();
import profileController from '../controllers/ProfileController.js';

router.post('/register', profileController.register);
router.post('/login', profileController.login);
router.post('/preferences', profileController.setPreferences);

router.get('/saved-places', profileController.getSavedPlaces);     // Fetch list
router.post('/saved-places', profileController.addSavedPlace);     // Add item
router.delete('/saved-places', profileController.removeSavedPlace); // Remove item  
export default router;
