import { Router } from 'express';
const router = Router();
import AIController from '../controllers/AIController.js';
import validateBearerToken from '../middleware/validateBearerToken.js';

// AI ask endpoint
router.post('/send-prompt', validateBearerToken, AIController.sendPrompt);
router.get('/extract-tags', AIController.extractTags);
router.post('/generate-reviews', AIController.generateReviews);

export default router;