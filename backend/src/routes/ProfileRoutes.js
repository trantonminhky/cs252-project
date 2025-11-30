import { Router } from 'express';
const router = Router();
import profileController from '../controllers/ProfileController';

router.post('/register', profileController.register);
router.post('/login', profileController.login);

export default router;