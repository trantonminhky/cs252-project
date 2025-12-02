import { Router } from 'express';
const router = Router();
import profileController from '../controllers/ProfileController.js';

router.post('/register', profileController.register);
router.post('/login', profileController.login);
router.post('/preferences', profileController.setPreferences);

export default router;
