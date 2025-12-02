import { Router } from 'express';
const router = Router();
import AIController from '../controllers/AIController.js';

// AI ask endpoint
router.post('/send-prompt', AIController.sendPrompt);
router.get('/extract-tags', AIController.extractTags);
router.post('/generate-reviews', AIController.generateReviews);

export default router;