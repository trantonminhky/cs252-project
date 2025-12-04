import { Router } from 'express';
const router = Router();
import AIController from '../controllers/AIController.js';
import ValidatorMiddleware from '../middleware/ValidatorMiddleware.js';

router.all('/send-prompt',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateSessionToken,
	ValidatorMiddleware.validateContentType,
	AIController.sendPrompt
);

router.all('/extract-tags',
	ValidatorMiddleware.validateMethods(['GET', 'HEAD']),
	AIController.extractTags
);

router.all('/generate-reviews',
	ValidatorMiddleware.validateMethods(['POST']),
	ValidatorMiddleware.validateSessionToken,
	ValidatorMiddleware.validateContentType,
	AIController.generateReviews
);

export default router;