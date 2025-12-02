import { Router } from 'express';
const router = Router();
import EventController from '../controllers/EventController.js';

router.post('/create', EventController.createEvent);

export default router;