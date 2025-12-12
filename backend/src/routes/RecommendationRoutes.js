import { Router } from 'express';
const router = Router();
import recController from '../controllers/RecommendationController.js'
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.all('/',
	ValidatorMiddleware.validateMethods(['GET', 'HEAD']),
	recController.getRecommendations
);

router.all('/feedback',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateContentType,
	recController.sendFeedback
);

export default router
