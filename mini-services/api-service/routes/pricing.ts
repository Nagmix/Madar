import { Router } from 'express';
import { db } from '../db';
import { authMiddleware, type AuthRequest } from '../middleware/auth';

const router = Router();

// Pricing Tiers
router.get('/tiers', authMiddleware, async (req, res) => {
  try {
    const tiers = await db.pricingTier.findMany({ include: { zonePricings: true }, orderBy: { vehicleType: 'asc' } });
    return res.json({ success: true, data: tiers });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

router.post('/tiers', authMiddleware, async (req, res) => {
  try {
    const tier = await db.pricingTier.create({ data: req.body });
    return res.json({ success: true, data: tier });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

router.put('/tiers/:id', authMiddleware, async (req, res) => {
  try {
    const tier = await db.pricingTier.update({ where: { id: req.params.id }, data: req.body });
    return res.json({ success: true, data: tier });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

// Surge Pricing
router.get('/surge', authMiddleware, async (req, res) => {
  try {
    const surge = await db.surgePricing.findMany({ orderBy: { createdAt: 'desc' } });
    return res.json({ success: true, data: surge });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

router.post('/surge', authMiddleware, async (req, res) => {
  try {
    const surge = await db.surgePricing.create({ data: req.body });
    return res.json({ success: true, data: surge });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

router.put('/surge/:id', authMiddleware, async (req, res) => {
  try {
    const surge = await db.surgePricing.update({ where: { id: req.params.id }, data: req.body });
    return res.json({ success: true, data: surge });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

// Zone Pricing
router.get('/zones', authMiddleware, async (req, res) => {
  try {
    const zones = await db.zonePricing.findMany({ include: { pricingTier: true } });
    return res.json({ success: true, data: zones });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

router.post('/zones', authMiddleware, async (req, res) => {
  try {
    const zone = await db.zonePricing.create({ data: req.body });
    return res.json({ success: true, data: zone });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

export default router;
