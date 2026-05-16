import { Router } from 'express';
import { db } from '../db';
import { authMiddleware, type AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/dashboard/stats
router.get('/stats', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const [totalRiders, totalDrivers, totalTrips, onlineDrivers, activeTrips, completedTrips] = await Promise.all([
      db.rider.count(),
      db.driver.count(),
      db.trip.count(),
      db.driver.count({ where: { isOnline: true } }),
      db.trip.count({ where: { status: { in: ['SEARCHING_DRIVER', 'DRIVER_ASSIGNED', 'DRIVER_ARRIVING', 'DRIVER_ARRIVED', 'TRIP_STARTED', 'TRIP_PAUSED', 'TRIP_RESUMED'] } } }),
      db.trip.count({ where: { status: 'TRIP_COMPLETED' } }),
    ]);

    const revenueResult = await db.trip.aggregate({ _sum: { totalFare: true }, where: { status: 'TRIP_COMPLETED' } });
    const totalRevenue = revenueResult._sum.totalFare || 0;

    const todayTrips = await db.trip.count({
      where: { requestedAt: { gte: new Date(new Date().setHours(0, 0, 0, 0)) } }
    });

    const todayRevenue = await db.trip.aggregate({
      _sum: { totalFare: true },
      where: { status: 'TRIP_COMPLETED', tripCompletedAt: { gte: new Date(new Date().setHours(0, 0, 0, 0)) } }
    });

    const pendingDrivers = await db.driver.count({ where: { status: 'PENDING_APPROVAL' } });
    const fraudAlerts = await db.fraudAlert.count({ where: { status: 'OPEN' } });

    return res.json({
      success: true,
      data: {
        totalRiders, totalDrivers, totalTrips, onlineDrivers, activeTrips,
        completedTrips, totalRevenue, todayTrips, todayRevenue: todayRevenue._sum.totalFare || 0,
        pendingDrivers, fraudAlerts
      }
    });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/dashboard/recent-trips
router.get('/recent-trips', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const trips = await db.trip.findMany({
      take: 10,
      orderBy: { requestedAt: 'desc' },
      include: { rider: { select: { id: true, name: true, phone: true, avatar: true } }, driver: { select: { id: true, name: true, phone: true, avatar: true } } }
    });
    return res.json({ success: true, data: trips });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/dashboard/revenue-chart
router.get('/revenue-chart', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const days = 7;
    const chartData = [];
    for (let i = days - 1; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      date.setHours(0, 0, 0, 0);
      const nextDate = new Date(date);
      nextDate.setDate(nextDate.getDate() + 1);
      const result = await db.trip.aggregate({
        _sum: { totalFare: true },
        _count: true,
        where: { status: 'TRIP_COMPLETED', tripCompletedAt: { gte: date, lt: nextDate } }
      });
      chartData.push({
        date: date.toISOString().split('T')[0],
        revenue: result._sum.totalFare || 0,
        trips: result._count
      });
    }
    return res.json({ success: true, data: chartData });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/dashboard/trips-by-status
router.get('/trips-by-status', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const statuses = ['SEARCHING_DRIVER', 'DRIVER_ASSIGNED', 'DRIVER_ARRIVING', 'DRIVER_ARRIVED', 'TRIP_STARTED', 'TRIP_COMPLETED', 'TRIP_CANCELLED', 'TRIP_EXPIRED'];
    const data: Record<string, number> = {};
    for (const status of statuses) {
      data[status] = await db.trip.count({ where: { status: status as any } });
    }
    return res.json({ success: true, data });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
