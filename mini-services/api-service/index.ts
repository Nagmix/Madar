import express from 'express';
import cors from 'cors';
import bcrypt from 'bcryptjs';
import { db } from './db';
import authRoutes from './routes/auth';
import dashboardRoutes from './routes/dashboard';
import driverRoutes from './routes/drivers';
import riderRoutes from './routes/riders';
import tripRoutes from './routes/trips';
import walletRoutes from './routes/wallets';
import pricingRoutes from './routes/pricing';
import fraudRoutes from './routes/fraud';
import zoneRoutes from './routes/zones';
import notificationRoutes from './routes/notifications';
import auditRoutes from './routes/audit';
import configRoutes from './routes/config';

const app = express();
const PORT = 3001;

app.use(cors({ origin: '*' }));
app.use(express.json({ limit: '10mb' }));

// Health check
app.get('/api/health', (_req, res) => {
  res.json({ success: true, service: 'trippo-api', version: '1.0.0', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/drivers', driverRoutes);
app.use('/api/riders', riderRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/wallets', walletRoutes);
app.use('/api/pricing', pricingRoutes);
app.use('/api/fraud', fraudRoutes);
app.use('/api/zones', zoneRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/audit', auditRoutes);
app.use('/api/config', configRoutes);

// Error handler
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('API Error:', err);
  res.status(500).json({ success: false, error: err.message || 'Internal server error' });
});

// Seed database
async function seedDatabase() {
  const adminExists = await db.user.findUnique({ where: { email: 'admin@trippo.com' } });
  if (adminExists) {
    console.log('Database already seeded, skipping...');
    return;
  }

  console.log('Seeding database...');

  // Admin user
  const passwordHash = await bcrypt.hash('admin123', 10);
  await db.user.create({ data: { email: 'admin@trippo.com', name: 'Admin', passwordHash, role: 'ADMIN' } });
  await db.user.create({ data: { email: 'dispatcher@trippo.com', name: 'Dispatcher', passwordHash, role: 'DISPATCHER' } });

  // Pricing tiers
  const sedanTier = await db.pricingTier.create({ data: { name: 'سيدان', vehicleType: 'SEDAN', baseFare: 8, perKmRate: 1.5, perMinuteRate: 0.3, minimumFare: 12, cancellationFee: 5, waitingFeePerMinute: 0.5, freeWaitingMinutes: 3 } });
  const suvTier = await db.pricingTier.create({ data: { name: 'SUV', vehicleType: 'SUV', baseFare: 12, perKmRate: 2.0, perMinuteRate: 0.4, minimumFare: 18, cancellationFee: 8, waitingFeePerMinute: 0.6, freeWaitingMinutes: 3 } });
  const luxuryTier = await db.pricingTier.create({ data: { name: 'فاخر', vehicleType: 'LUXURY', baseFare: 20, perKmRate: 3.5, perMinuteRate: 0.6, minimumFare: 30, cancellationFee: 15, waitingFeePerMinute: 1.0, freeWaitingMinutes: 5 } });
  const motorcycleTier = await db.pricingTier.create({ data: { name: 'دراجة', vehicleType: 'MOTORCYCLE', baseFare: 5, perKmRate: 0.8, perMinuteRate: 0.2, minimumFare: 8, cancellationFee: 3, waitingFeePerMinute: 0.3, freeWaitingMinutes: 2 } });

  // Surge pricing
  await db.surgePricing.create({ data: { name: 'ساعات الذروة الصباحية', multiplier: 1.5, startTime: '07:00', endTime: '09:00', daysOfWeek: '[0,1,2,3,4]' } });
  await db.surgePricing.create({ data: { name: 'ساعات الذروة المسائية', multiplier: 1.8, startTime: '17:00', endTime: '20:00', daysOfWeek: '[0,1,2,3,4]' } });
  await db.surgePricing.create({ data: { name: 'عطلة نهاية الأسبوع ليلاً', multiplier: 2.0, startTime: '22:00', endTime: '02:00', daysOfWeek: '[4,5]' } });

  // Service zones
  await db.serviceZone.create({ data: { name: 'وسط المدينة', nameAr: 'وسط المدينة', type: 'SERVICE_AREA', coordinates: JSON.stringify([[24.7136, 46.6753], [24.7236, 46.6853], [24.7336, 46.6753], [24.7136, 46.6753]]), centerLat: 24.7236, centerLng: 46.6803, radius: 10, isActive: true } });
  await db.serviceZone.create({ data: { name: 'المطار', nameAr: 'المطار', type: 'AIRPORT', coordinates: JSON.stringify([[24.9578, 46.6988], [24.9678, 46.7088], [24.9778, 46.6988], [24.9578, 46.6988]]), centerLat: 24.9678, centerLng: 46.7038, radius: 5, isActive: true } });
  await db.serviceZone.create({ data: { name: 'منقة التوصيل', nameAr: 'منقة التوصيل', type: 'SURGE_ZONE', coordinates: JSON.stringify([[24.70, 46.67], [24.73, 46.70], [24.76, 46.67], [24.70, 46.67]]), centerLat: 24.73, centerLng: 46.68, radius: 8, isActive: true } });

  // Drivers
  const driverNames = ['أحمد محمد', 'خالد عبدالله', 'سعد العتيبي', 'فهد الدوسري', 'محمد القحطاني', 'عبدالرحمن الشهري', 'يوسف الحربي', 'ناصر المالكي', 'تركي السبيعي', 'عمر الزهراني'];
  const driverStatuses = ['ONLINE', 'OFFLINE', 'ON_TRIP', 'ONLINE', 'OFFLINE', 'PENDING_APPROVAL', 'ONLINE', 'BUSY', 'ONLINE', 'OFFLINE'] as any[];
  const vehicleTypes = ['SEDAN', 'SUV', 'SEDAN', 'LUXURY', 'SEDAN', 'SUV', 'MOTORCYCLE', 'SEDAN', 'SUV', 'SEDAN'] as any[];
  const carModels = [['تويوتا', 'كامري', 2022], ['هيونداي', 'توسان', 2023], ['نيسان', 'صني', 2021], ['مرسيدس', 'E200', 2023], ['تويوتا', 'كورولا', 2022], ['كيا', 'سبورتاج', 2023], ['هوندا', 'CBR', 2022], ['تويوتا', 'يارس', 2021], ['هيونداي', 'النترا', 2023], ['نيسان', 'بترول', 2022]];
  const colors = ['أبيض', 'أسود', 'فضي', 'أسود', 'أبيض', 'أزرق', 'أحمر', 'فضي', 'أبيض', 'رمادي'];
  const plates = ['أ ب ج 1234', 'د هـ و 5678', 'ز ح ط 9012', 'ي ك ل 3456', 'م ن س 7890', 'ع ف ص 2345', 'ق ر ش 6789', 'ت ث خ 0123', 'ذ ض ظ 4567', 'غ مع 8901'];

  const driverIds: string[] = [];
  for (let i = 0; i < 10; i++) {
    const isOnline = driverStatuses[i] === 'ONLINE' || driverStatuses[i] === 'ON_TRIP' || driverStatuses[i] === 'BUSY';
    const driver = await db.driver.create({
      data: {
        email: `driver${i + 1}@trippo.com`, name: driverNames[i], phone: `+96650${10000000 + i}`,
        status: driverStatuses[i], isOnline, isVerified: i !== 5,
        rating: 4.0 + Math.random() * 1.0, totalTrips: Math.floor(Math.random() * 500) + 50,
        acceptedTrips: Math.floor(Math.random() * 400) + 40, rejectedTrips: Math.floor(Math.random() * 30),
        acceptanceRate: 80 + Math.random() * 20, cancellationRate: Math.random() * 10,
        totalOnlineHours: Math.floor(Math.random() * 2000) + 100, lastOnlineAt: isOnline ? new Date() : null,
        vehicle: {
          create: { type: vehicleTypes[i], make: carModels[i][0] as string, model: carModels[i][1] as string, year: carModels[i][2] as number, color: colors[i], plateNumber: plates[i], capacity: vehicleTypes[i] === 'SUV' ? 6 : vehicleTypes[i] === 'MOTORCYCLE' ? 1 : 4 }
        },
        wallet: { create: { ownerType: 'driver', balance: Math.floor(Math.random() * 5000) + 500, currency: 'SAR' } }
      }
    });
    driverIds.push(driver.id);

    // Add locations for online drivers
    if (isOnline) {
      await db.driverLocation.create({
        data: { driverId: driver.id, latitude: 24.7136 + (Math.random() - 0.5) * 0.05, longitude: 46.6753 + (Math.random() - 0.5) * 0.05, heading: Math.random() * 360, speed: Math.random() * 60, accuracy: 5 + Math.random() * 10 }
      });
    }
  }

  // Riders
  const riderNames = ['محمد أحمد', 'عبدالله سعد', 'فاطمة خالد', 'نورة محمد', 'سلطان فهد', 'ريم عبدالعزيز', 'ماجد تركي', 'هند ناصر', 'بندر يوسف', 'لمياء عمر'];
  const riderIds: string[] = [];
  for (let i = 0; i < 10; i++) {
    const rider = await db.rider.create({
      data: {
        email: `rider${i + 1}@trippo.com`, name: riderNames[i], phone: `+96655${10000000 + i}`,
        status: 'ACTIVE', isVerified: true, rating: 3.5 + Math.random() * 1.5,
        totalRides: Math.floor(Math.random() * 100) + 5, cancelledRides: Math.floor(Math.random() * 10),
        cancellationRate: Math.random() * 10,
        wallet: { create: { ownerType: 'rider', balance: Math.floor(Math.random() * 500) + 50, currency: 'SAR' } }
      }
    });
    riderIds.push(rider.id);
  }

  // Trips
  const tripStatuses = ['TRIP_COMPLETED', 'TRIP_COMPLETED', 'TRIP_STARTED', 'DRIVER_ARRIVING', 'SEARCHING_DRIVER', 'TRIP_CANCELLED', 'TRIP_COMPLETED', 'PAYMENT_PENDING', 'TRIP_COMPLETED', 'DRIVER_ASSIGNED'] as any[];
  const addresses = ['شارع الملك فهد', 'طريق الأمير سلطان', 'حي العليا', 'حي السليمانية', 'شارع التحلية', 'طريق الملك عبدالله', 'حي النخيل', 'شارع الحمراء', 'حي الورود', 'طريق أنس بن مالك'];
  let tripCounter = 1000;

  for (let i = 0; i < 10; i++) {
    const originLat = 24.7136 + (Math.random() - 0.5) * 0.08;
    const originLng = 46.6753 + (Math.random() - 0.5) * 0.08;
    const destLat = 24.7136 + (Math.random() - 0.5) * 0.08;
    const destLng = 46.6753 + (Math.random() - 0.5) * 0.08;
    const distance = Math.floor(2000 + Math.random() * 15000);
    const duration = Math.floor(180 + Math.random() * 1800);
    const baseFare = 8;
    const distanceFare = (distance / 1000) * 1.5;
    const timeFare = (duration / 60) * 0.3;
    const totalFare = baseFare + distanceFare + timeFare;
    const requestedAt = new Date(Date.now() - Math.random() * 7 * 24 * 60 * 60 * 1000);

    const isCompleted = tripStatuses[i] === 'TRIP_COMPLETED';
    const isStarted = ['TRIP_STARTED', 'DRIVER_ARRIVING', 'DRIVER_ARRIVED', 'TRIP_COMPLETED', 'PAYMENT_PENDING'].includes(tripStatuses[i]);

    await db.trip.create({
      data: {
        tripNumber: `TRP-${++tripCounter}`,
        riderId: riderIds[i],
        driverId: tripStatuses[i] !== 'SEARCHING_DRIVER' ? driverIds[i % driverIds.length] : null,
        originAddress: addresses[i], originLat, originLng,
        destinationAddress: addresses[(i + 5) % 10], destinationLat: destLat, destinationLng: destLng,
        distanceMeters: distance, durationSeconds: duration,
        status: tripStatuses[i],
        baseFare, distanceFare: Math.round(distanceFare * 100) / 100, timeFare: Math.round(timeFare * 100) / 100,
        totalFare: Math.round(totalFare * 100) / 100, surgeMultiplier: 1.0,
        paymentMethod: i % 3 === 0 ? 'CASH' : i % 3 === 1 ? 'CARD' : 'WALLET',
        paymentStatus: isCompleted ? 'COMPLETED' : 'PENDING',
        vehicleTypeRequested: 'SEDAN',
        requestedAt,
        driverAssignedAt: isStarted ? new Date(requestedAt.getTime() + 30000) : undefined,
        tripStartedAt: isStarted ? new Date(requestedAt.getTime() + 120000) : undefined,
        tripCompletedAt: isCompleted ? new Date(requestedAt.getTime() + duration * 1000) : undefined,
        paymentCompletedAt: isCompleted ? new Date(requestedAt.getTime() + duration * 1000 + 5000) : undefined,
        riderRating: isCompleted ? 4 + Math.random() : null,
        driverRating: isCompleted ? 4 + Math.random() : null,
        tripEvents: {
          create: [
            { status: 'SEARCHING_DRIVER', actor: 'rider', actorId: riderIds[i], createdAt: requestedAt },
            ...(isStarted ? [{ status: 'DRIVER_ASSIGNED' as any, actor: 'system' as any, createdAt: new Date(requestedAt.getTime() + 30000) }] : []),
            ...(isCompleted ? [{ status: 'TRIP_COMPLETED' as any, actor: 'driver' as any, actorId: driverIds[i % driverIds.length], createdAt: new Date(requestedAt.getTime() + duration * 1000) }] : []),
          ]
        },
        payment: isCompleted ? { create: { amount: totalFare, method: i % 3 === 0 ? 'CASH' : i % 3 === 1 ? 'CARD' : 'WALLET', status: 'COMPLETED', processedAt: new Date() } } : undefined,
      }
    });
  }

  // Fraud alerts
  await db.fraudAlert.create({ data: { type: 'gps_spoofing', severity: 'HIGH', status: 'OPEN', driverId: driverIds[2], description: 'تم اكتشاف تلاعب في إحداثيات GPS - انتقال مستحيل بين المواقع', evidence: JSON.stringify({ jumpDistance: '15km', timeDiff: '30s' }) } });
  await db.fraudAlert.create({ data: { type: 'fake_account', severity: 'CRITICAL', status: 'INVESTIGATING', riderId: riderIds[4], description: 'حساب وهمي محتمل - نفس الجهاز لعدة حسابات', evidence: JSON.stringify({ deviceId: 'dev_xxx', accountCount: 5 }) } });
  await db.fraudAlert.create({ data: { type: 'ghost_trip', severity: 'MEDIUM', status: 'OPEN', driverId: driverIds[7], description: 'رحلة مزورة محتملة - السائق والراكب في نفس الموقع دائماً', evidence: JSON.stringify({ sameLocationCount: 8 }) } });

  // System config
  const configs = [
    { key: 'commission_rate', value: '20', type: 'number', group: 'pricing', description: 'نسبة العمولة من السائقين' },
    { key: 'max_search_radius_km', value: '25', type: 'number', group: 'dispatch', description: 'أقصى نصف قطر للبحث عن سائق' },
    { key: 'driver_offer_timeout_sec', value: '30', type: 'number', group: 'dispatch', description: 'مهلة عرض الرحلة للسائق' },
    { key: 'max_dispatch_attempts', value: '3', type: 'number', group: 'dispatch', description: 'عدد محاولات البحث عن سائق' },
    { key: 'min_driver_rating', value: '3.5', type: 'number', group: 'quality', description: 'أقل تقييم مسموح للسائق' },
    { key: 'auto_cancel_minutes', value: '5', type: 'number', group: 'trips', description: 'إلغاء تلقائي بعد دقائق بدون سائق' },
    { key: 'google_maps_api_key', value: '', type: 'string', group: 'maps', description: 'مفتاح Google Maps API' },
    { key: 'fcm_server_key', value: '', type: 'string', group: 'notifications', description: 'مفتاح Firebase Cloud Messaging' },
    { key: 'default_currency', value: 'SAR', type: 'string', group: 'general', description: 'العملة الافتراضية' },
    { key: 'support_phone', value: '+966800000000', type: 'string', group: 'general', description: 'رقم الدعم' },
  ];
  for (const config of configs) {
    await db.systemConfig.create({ data: config });
  }

  console.log('Database seeded successfully!');
}

// Start server
async function start() {
  try {
    await seedDatabase();
    app.listen(PORT, () => {
      console.log(`Trippo API Service running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start API service:', error);
    process.exit(1);
  }
}

start();
