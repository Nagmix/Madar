import { Router } from 'express';
import { db } from '../db';
import { authMiddleware, type AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/trips
router.get('/', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const status = req.query.status as string;
    const search = req.query.search as string;
    const startDate = req.query.startDate as string;
    const endDate = req.query.endDate as string;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (status) where.status = status;
    if (search) where.tripNumber = { contains: search };
    if (startDate || endDate) {
      where.requestedAt = {};
      if (startDate) where.requestedAt.gte = new Date(startDate);
      if (endDate) where.requestedAt.lt = new Date(new Date(endDate).getTime() + 86400000);
    }

    const [trips, total] = await Promise.all([
      db.trip.findMany({
        where, skip, take: limit, orderBy: { requestedAt: 'desc' },
        include: {
          rider: { select: { id: true, name: true, phone: true, avatar: true } },
          driver: { select: { id: true, name: true, phone: true, avatar: true } }
        }
      }),
      db.trip.count({ where })
    ]);

    return res.json({ success: true, data: trips, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/trips/stats
router.get('/stats', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const [total, completed, cancelled, avgFare] = await Promise.all([
      db.trip.count(),
      db.trip.count({ where: { status: 'TRIP_COMPLETED' } }),
      db.trip.count({ where: { status: 'TRIP_CANCELLED' } }),
      db.trip.aggregate({ _avg: { totalFare: true }, where: { status: 'TRIP_COMPLETED' } })
    ]);
    const avgDistance = await db.trip.aggregate({ _avg: { distanceMeters: true }, where: { status: 'TRIP_COMPLETED' } });
    return res.json({
      success: true,
      data: { total, completed, cancelled, completionRate: total > 0 ? ((completed / total) * 100).toFixed(1) : '0', avgFare: avgFare._avg.totalFare || 0, avgDistance: avgDistance._avg.distanceMeters || 0 }
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/trips/:id
router.get('/:id', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const trip = await db.trip.findUnique({
      where: { id: req.params.id },
      include: {
        rider: { select: { id: true, name: true, phone: true, avatar: true } },
        driver: { select: { id: true, name: true, phone: true, avatar: true, vehicle: true } },
        tripEvents: { orderBy: { createdAt: 'asc' } },
        tripLocations: { orderBy: { recordedAt: 'asc' } },
        payment: true,
        promoUsage: { include: { promoCode: true } }
      }
    });
    if (!trip) return res.status(404).json({ success: false, error: 'Trip not found' });
    return res.json({ success: true, data: trip });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// PUT /api/trips/:id/status
router.put('/:id/status', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { status } = req.body;
    const trip = await db.trip.update({ where: { id: req.params.id }, data: { status } });
    await db.tripEvent.create({
      data: { tripId: trip.id, status: status as any, actor: 'admin', actorId: req.user!.id }
    });
    await db.auditLog.create({
      data: { userId: req.user!.id, action: 'UPDATE_TRIP_STATUS', entity: 'Trip', entityId: trip.id, changes: JSON.stringify({ status }) }
    });
    return res.json({ success: true, data: trip });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/trips/:id/cancel
router.post('/:id/cancel', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { cancelReason, cancelReasonText } = req.body;
    const trip = await db.trip.update({
      where: { id: req.params.id },
      data: { status: 'TRIP_CANCELLED', cancelReason: cancelReason || 'SYSTEM_CANCELLED', cancelReasonText, tripCancelledAt: new Date() }
    });
    await db.tripEvent.create({
      data: { tripId: trip.id, status: 'TRIP_CANCELLED', actor: 'admin', actorId: req.user!.id, metadata: JSON.stringify({ cancelReason, cancelReasonText }) }
    });
    return res.json({ success: true, data: trip });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
