import { Router } from 'express';
const router = Router();
import recController from '../controllers/RecommendationController.js';
import validateContentType from '../middleware/validateContentType.js';

router.get('/', recController.getRecommendations);
router.post('/feedback', validateContentType, recController.sendFeedback);

export default router
