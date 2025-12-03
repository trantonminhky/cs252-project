import { Router } from 'express';
const router = Router();
import AIController from '../controllers/AIController.js';
import validateBearerToken from '../middleware/validateBearerToken.js';
import validateContentType from '../middleware/validateContentType.js';

// AI ask endpoint
router.post('/send-prompt', validateBearerToken, validateContentType, AIController.sendPrompt);
router.get('/extract-tags', AIController.extractTags);
router.post('/generate-reviews', validateBearerToken, validateContentType, AIController.generateReviews);

export default router;