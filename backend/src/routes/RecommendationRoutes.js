import { Router } from 'express';
const router = Router();
import recController from '../controllers/RecommendationController.js'
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.get('/',
	recController.getRecommendations
);

router.post('/feedback',
	ValidatorMiddleware.validateContentType,
	recController.sendFeedback
);

export default router
