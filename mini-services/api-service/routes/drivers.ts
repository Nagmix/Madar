import { Router } from 'express';
import { db } from '../db';
import { authMiddleware, type AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/drivers
router.get('/', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const search = req.query.search as string;
    const status = req.query.status as string;
    const skip = (page - 1) * limit;

    const where: any = {};
    if (search) {
      where.OR = [
        { name: { contains: search } },
        { email: { contains: search } },
        { phone: { contains: search } },
      ];
    }
    if (status) where.status = status;

    const [drivers, total] = await Promise.all([
      db.driver.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' }, include: { vehicle: true } }),
      db.driver.count({ where })
    ]);

    return res.json({ success: true, data: drivers, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/drivers/online
router.get('/online', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const drivers = await db.driver.findMany({
      where: { isOnline: true, status: { notIn: ['SUSPENDED', 'BANNED'] } },
      include: { vehicle: true, driverLocations: { take: 1, orderBy: { createdAt: 'desc' } } }
    });
    return res.json({ success: true, data: drivers });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/drivers/:id
router.get('/:id', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const driver = await db.driver.findUnique({
      where: { id: req.params.id },
      include: { vehicle: true, wallet: true, documents: true, driverLocations: { take: 20, orderBy: { createdAt: 'desc' } } }
    });
    if (!driver) return res.status(404).json({ success: false, error: 'Driver not found' });
    return res.json({ success: true, data: driver });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// PUT /api/drivers/:id
router.put('/:id', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { name, phone, emergencyContact, emergencyName, bankAccountNumber, bankName, bankIban, preferredLanguage } = req.body;
    const driver = await db.driver.update({
      where: { id: req.params.id },
      data: { name, phone, emergencyContact, emergencyName, bankAccountNumber, bankName, bankIban, preferredLanguage }
    });
    return res.json({ success: true, data: driver });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// PUT /api/drivers/:id/status
router.put('/:id/status', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { status, reason } = req.body;
    const driver = await db.driver.update({
      where: { id: req.params.id },
      data: { status, isOnline: status === 'ONLINE' }
    });
    await db.auditLog.create({
      data: { userId: req.user!.id, action: 'UPDATE_DRIVER_STATUS', entity: 'Driver', entityId: driver.id, changes: JSON.stringify({ status, reason }) }
    });
    return res.json({ success: true, data: driver });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// PUT /api/drivers/:id/verify
router.put('/:id/verify', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { documentId, status, rejectionReason } = req.body;
    if (documentId) {
      await db.driverDocument.update({
        where: { id: documentId },
        data: { status, reviewedBy: req.user!.id, reviewedAt: new Date(), rejectionReason }
      });
    }
    const driver = await db.driver.update({
      where: { id: req.params.id },
      data: { isVerified: status === 'approved' }
    });
    return res.json({ success: true, data: driver });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/drivers/:id/trips
router.get('/:id/trips', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const trips = await db.trip.findMany({
      where: { driverId: req.params.id },
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { requestedAt: 'desc' },
      include: { rider: { select: { id: true, name: true, phone: true } } }
    });
    const total = await db.trip.count({ where: { driverId: req.params.id } });
    return res.json({ success: true, data: trips, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
