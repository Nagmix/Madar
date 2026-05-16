import { Router } from 'express';
import { db } from '../db';
import { authMiddleware, type AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/wallets
router.get('/', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const wallets = await db.wallet.findMany({ skip: (page - 1) * limit, take: limit, orderBy: { updatedAt: 'desc' }, include: { transactions: { take: 5, orderBy: { createdAt: 'desc' } } } });
    const total = await db.wallet.count();
    return res.json({ success: true, data: wallets, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/wallets/:ownerId
router.get('/:ownerId', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const wallet = await db.wallet.findUnique({
      where: { ownerId: req.params.ownerId },
      include: { transactions: { take: 50, orderBy: { createdAt: 'desc' } } }
    });
    if (!wallet) return res.status(404).json({ success: false, error: 'Wallet not found' });
    return res.json({ success: true, data: wallet });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/wallets/:ownerId/adjust
router.post('/:ownerId/adjust', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { amount, type, description } = req.body; // type: CREDIT or DEBIT
    const wallet = await db.wallet.findUnique({ where: { ownerId: req.params.ownerId } });
    if (!wallet) return res.status(404).json({ success: false, error: 'Wallet not found' });
    const newBalance = type === 'CREDIT' ? wallet.balance + amount : wallet.balance - amount;
    if (newBalance < 0) return res.status(400).json({ success: false, error: 'Insufficient balance' });
    await db.wallet.update({ where: { ownerId: req.params.ownerId }, data: { balance: newBalance } });
    await db.transaction.create({
      data: { walletId: wallet.id, type: type as any, amount, description: description || `Admin ${type.toLowerCase()}`, status: 'COMPLETED', referenceType: 'admin_adjustment' }
    });
    await db.auditLog.create({ data: { userId: req.user!.id, action: 'ADJUST_WALLET', entity: 'Wallet', entityId: wallet.id, changes: JSON.stringify({ amount, type, newBalance }) } });
    return res.json({ success: true, data: { balance: newBalance } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/transactions
router.get('/transactions/list', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const type = req.query.type as string;
    const where: any = {};
    if (type) where.type = type;
    const [transactions, total] = await Promise.all([
      db.transaction.findMany({ where, skip: (page - 1) * limit, take: limit, orderBy: { createdAt: 'desc' } }),
      db.transaction.count({ where })
    ]);
    return res.json({ success: true, data: transactions, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/payments
router.get('/payments/list', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const [payments, total] = await Promise.all([
      db.payment.findMany({ skip: (page - 1) * limit, take: limit, orderBy: { createdAt: 'desc' }, include: { trip: { select: { tripNumber: true, rider: { select: { name: true } }, driver: { select: { name: true } } } } } }),
      db.payment.count()
    ]);
    return res.json({ success: true, data: payments, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/settlements
router.get('/settlements/list', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const [settlements, total] = await Promise.all([
      db.settlement.findMany({ skip: (page - 1) * limit, take: limit, orderBy: { createdAt: 'desc' }, include: { driver: { select: { name: true, email: true } } } }),
      db.settlement.count()
    ]);
    return res.json({ success: true, data: settlements, pagination: { page, limit, total, pages: Math.ceil(total / limit) } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/settlements/generate
router.post('/settlements/generate', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { driverId } = req.body;
    const driver = await db.driver.findUnique({ where: { id: driverId }, include: { wallet: true } });
    if (!driver || !driver.wallet) return res.status(404).json({ success: false, error: 'Driver or wallet not found' });

    const completedTrips = await db.trip.findMany({
      where: { driverId, status: 'TRIP_COMPLETED', tripCompletedAt: { gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } }
    });

    const totalEarnings = completedTrips.reduce((sum, t) => sum + t.totalFare, 0);
    const commission = totalEarnings * 0.2; // 20% commission
    const netAmount = totalEarnings - commission;

    const settlement = await db.settlement.create({
      data: {
        driverId, walletId: driver.wallet.id,
        periodStart: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
        periodEnd: new Date(),
        totalTrips: completedTrips.length,
        totalEarnings, commission, netAmount,
        status: 'pending'
      }
    });

    return res.json({ success: true, data: settlement });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
