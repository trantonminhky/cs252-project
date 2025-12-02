import { Router } from 'express';
import recController from '../controllers/RecommendationController.js';

const router = Router();

router.get('/', recController.getRecommendations);
router.post('/feedback', recController.sendFeedback);

export default router;