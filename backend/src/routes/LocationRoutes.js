import { Router } from 'express';
const router = Router();
import LocationController from '../controllers/LocationController';

router.get('/import', LocationController.importToDB);
router.get('/search', LocationController.search);

export default router;