import { Router } from 'express';
const router = Router();
import AIController from '../controllers/AIController';

// AI ask endpoint
router.post('/send-prompt', AIController.sendPrompt);
router.get('/extract-tags', AIController.extractTags);

export default router;