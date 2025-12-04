import { Router } from 'express';
const router = Router();
import AIController from '../controllers/AIController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.post('/send-prompt',
	ValidatorMiddleware.validateSessionToken,
	ValidatorMiddleware.validateContentType,
	AIController.sendPrompt
);

router.get('/extract-tags',
	AIController.extractTags
);

router.post('/generate-reviews',
	ValidatorMiddleware.validateSessionToken,
	ValidatorMiddleware.validateContentType,
	AIController.generateReviews
);

export default router;