import { Router } from 'express';
const router = Router();
import AIController from '../controllers/AIController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.post('/send-prompt',
	ValidatorMiddleware.validateBearerToken,
	ValidatorMiddleware.validateContentType,
	AIController.sendPrompt
);

router.get('/extract-tags',
	AIController.extractTags
);

router.post('/generate-reviews',
	ValidatorMiddleware.validateBearerToken,
	ValidatorMiddleware.validateContentType,
	AIController.generateReviews
);

export default router;