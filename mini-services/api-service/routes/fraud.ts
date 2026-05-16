import { Router } from 'express';
import { db } from '../db';
import { authMiddleware, type AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/fraud/alerts
router.get('/alerts', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const status = req.query.status as string;
    const severity = req.query.severity as string;
    const where: any = {};
    if (status) where.status = status;
    if (severity) where.severity = severity;

    const [alerts, total] = await Promise.all([
      db.fraudAlert.findMany({ where, skip: (page - 1) * limit, take: limit, orderBy: { createdAt: 'desc' }, include: { rider: { select: { name: true } }, driver: { select: { name: true } } } }),
      db.fraudAlert.count({ where })
    ]);
    return res.json({ success: true, data: alerts, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// PUT /api/fraud/alerts/:id
router.put('/alerts/:id', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { status, resolution } = req.body;
    const alert = await db.fraudAlert.update({
      where: { id: req.params.id },
      data: { status, resolution, resolvedBy: req.user!.id, resolvedAt: new Date() }
    });
    return res.json({ success: true, data: alert });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/fraud/stats
router.get('/stats', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const [total, open, critical, gpsSpoofing, fakeAccounts, ghostTrips] = await Promise.all([
      db.fraudAlert.count(),
      db.fraudAlert.count({ where: { status: 'OPEN' } }),
      db.fraudAlert.count({ where: { severity: 'CRITICAL', status: { notIn: ['RESOLVED', 'FALSE_POSITIVE'] } } }),
      db.fraudAlert.count({ where: { type: 'gps_spoofing' } }),
      db.fraudAlert.count({ where: { type: 'fake_account' } }),
      db.fraudAlert.count({ where: { type: 'ghost_trip' } }),
    ]);
    return res.json({ success: true, data: { total, open, critical, gpsSpoofing, fakeAccounts, ghostTrips } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
