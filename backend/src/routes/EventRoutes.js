import { Router } from 'express';
const router = Router();
import EventController from '../controllers/EventController.js';
import validateContentType from '../middleware/validateContentType.js';

router.get('/import', EventController.importToDB);
router.post('/create', validateContentType, EventController.createEvent);
router.post('/subscribe', validateContentType, EventController.subscribe);
router.post('/unsubscribe', validateContentType, EventController.unsubscribe);
router.get('/get-by-username', EventController.getByUsername);

export default router;