import { Router } from 'express';
const router = Router();
import mapController from '../controllers/MapController.js';
import validateBearerToken from '../middleware/validateBearerToken.js';
import validateContentType from '../middleware/validateContentType.js';

router.post('/route', validateBearerToken, validateContentType, mapController.getRoute);
router.get('/nearby', validateBearerToken, mapController.nearby);

export default router;