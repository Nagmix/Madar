import { Router } from 'express';
import { db } from '../db';
import { authMiddleware, type AuthRequest } from '../middleware/auth';

const router = Router();

// GET /api/config
router.get('/', authMiddleware, async (req, res) => {
  try {
    const configs = await db.systemConfig.findMany({ orderBy: { group: 'asc' } });
    return res.json({ success: true, data: configs });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

// PUT /api/config/:key
router.put('/:key', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const { value } = req.body;
    const config = await db.systemConfig.upsert({
      where: { key: req.params.key },
      update: { value },
      create: { key: req.params.key, value }
    });
    await db.auditLog.create({ data: { userId: req.user!.id, action: 'UPDATE_CONFIG', entity: 'SystemConfig', entityId: config.id, changes: JSON.stringify({ key: config.key, value }) } });
    return res.json({ success: true, data: config });
  } catch (error: any) { return res.status(500).json({ success: false, error: error.message }); }
});

export default router;
