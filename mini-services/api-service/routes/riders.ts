import { Router } from 'express';
import { db } from '../db';
import { authMiddleware, type AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/riders
router.get('/', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const search = req.query.search as string;
    const status = req.query.status as string;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (search) {
      where.OR = [{ name: { contains: search } }, { email: { contains: search } }, { phone: { contains: search } }];
    }
    if (status) where.status = status;

    const [riders, total] = await Promise.all([
      db.rider.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' }, include: { wallet: true } }),
      db.rider.count({ where })
    ]);

    return res.json({ success: true, data: riders, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/riders/:id
router.get('/:id', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const rider = await db.rider.findUnique({
      where: { id: req.params.id },
      include: { wallet: true, favoritePlaces: true }
    });
    if (!rider) return res.status(404).json({ success: false, error: 'Rider not found' });
    return res.json({ success: true, data: rider });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// PUT /api/riders/:id
router.put('/:id', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { name, phone, preferredLanguage } = req.body;
    const rider = await db.rider.update({ where: { id: req.params.id }, data: { name, phone, preferredLanguage } });
    return res.json({ success: true, data: rider });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// PUT /api/riders/:id/status
router.put('/:id/status', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { status } = req.body;
    const rider = await db.rider.update({ where: { id: req.params.id }, data: { status } });
    await db.auditLog.create({
      data: { userId: req.user!.id, action: 'UPDATE_RIDER_STATUS', entity: 'Rider', entityId: rider.id, changes: JSON.stringify({ status }) }
    });
    return res.json({ success: true, data: rider });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/riders/:id/trips
router.get('/:id/trips', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const trips = await db.trip.findMany({
      where: { riderId: req.params.id },
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { requestedAt: 'desc' },
      include: { driver: { select: { id: true, name: true, phone: true, avatar: true } } }
    });
    const total = await db.trip.count({ where: { riderId: req.params.id } });
    return res.json({ success: true, data: trips, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
