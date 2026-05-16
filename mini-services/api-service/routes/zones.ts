import { Router } from 'express';
import { db } from '../db';
import { authMiddleware, type AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/zones
router.get('/', authMiddleware, async (req, res) => {
  try {
    const zones = await db.serviceZone.findMany({ orderBy: { createdAt: 'desc' } });
    return res.json({ success: true, data: zones });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

// POST /api/zones
router.post('/', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const zone = await db.serviceZone.create({ data: req.body });
    await db.auditLog.create({ data: { userId: req.user!.id, action: 'CREATE_ZONE', entity: 'ServiceZone', entityId: zone.id } });
    return res.json({ success: true, data: zone });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

// PUT /api/zones/:id
router.put('/:id', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const zone = await db.serviceZone.update({ where: { id: req.params.id }, data: req.body });
    return res.json({ success: true, data: zone });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

// DELETE /api/zones/:id
router.delete('/:id', authMiddleware, async (req: AuthRequest, res) => {
  try {
    await db.serviceZone.delete({ where: { id: req.params.id } });
    return res.json({ success: true, data: { deleted: true } });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

export default router;
