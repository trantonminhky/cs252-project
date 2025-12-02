import { Router } from 'express';
const router = Router();
import EventController from '../controllers/EventController.js';

router.get('/import', EventController.importToDB);
router.post('/create', EventController.createEvent);
router.post('/subscribe', EventController.subscribe);
router.get('/get-by-username', EventController.getByUsername);

export default router;