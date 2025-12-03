import { Router } from 'express';
const router = Router();
import mapController from '../controllers/MapController.js';
import validateBearerToken from '../middleware/validateBearerToken.js';

router.post('/route', validateBearerToken, mapController.getRoute);
router.get('/nearby', validateBearerToken, mapController.nearby);

export default router;