import { Router } from 'express';
import { db } from '../db';
import { authMiddleware, type AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/notifications
router.get('/', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const [notifications, total] = await Promise.all([
      db.notification.findMany({ skip: (page - 1) * limit, take: limit, orderBy: { createdAt: 'desc' }, include: { rider: { select: { name: true } }, driver: { select: { name: true } } } }),
      db.notification.count()
    ]);
    return res.json({ success: true, data: notifications, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

// POST /api/notifications
router.post('/', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { riderId, driverId, type, channel, title, body, data } = req.body;
    const notification = await db.notification.create({ data: { riderId, driverId, type, channel, title, body, data: data ? JSON.stringify(data) : null, sentAt: new Date() } });
    return res.json({ success: true, data: notification });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

// GET /api/notifications/templates
router.get('/templates', authMiddleware, async (req, res) => {
  try {
    const templates = await db.notificationTemplate.findMany();
    return res.json({ success: true, data: templates });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

// POST /api/notifications/templates
router.post('/templates', authMiddleware, async (req, res) => {
  try {
    const template = await db.notificationTemplate.create({ data: req.body });
    return res.json({ success: true, data: template });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

export default router;
