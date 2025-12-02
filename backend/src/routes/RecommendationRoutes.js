import { Router } from 'express';
const router = Router();
import recController from '../controllers/RecommendationController.js';

router.get('/', recController.getRecommendations);
router.post('/feedback', recController.sendFeedback);

export default router