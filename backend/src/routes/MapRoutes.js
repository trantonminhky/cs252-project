import { Router } from 'express';
const router = Router();
import mapController from '../controllers/MapController.js';

router.post('/route', mapController.getRoute);
router.get('/nearby', mapController.nearby);

export default router;