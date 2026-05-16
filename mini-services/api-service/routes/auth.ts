import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { db } from '../db';
import { authMiddleware, generateToken, type AuthRequest } from '../middleware/auth';

const router = Router();

// POST /api/auth/login
router.post('/login', async (req: AuthRequest, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, error: 'Email and password required' });
    }
    const user = await db.user.findUnique({ where: { email } });
    if (!user || !user.passwordHash) {
      return res.status(401).json({ success: false, error: 'Invalid credentials' });
    }
    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) {
      return res.status(401).json({ success: false, error: 'Invalid credentials' });
    }
    await db.user.update({ where: { id: user.id }, data: { lastLoginAt: new Date() } });
    const token = generateToken({ id: user.id, email: user.email, role: user.role });
    return res.json({ success: true, data: { token, user: { id: user.id, email: user.email, name: user.name, role: user.role } } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { email, password, name, role } = req.body;
    if (!email || !password || !name) {
      return res.status(400).json({ success: false, error: 'Email, password and name required' });
    }
    const exists = await db.user.findUnique({ where: { email } });
    if (exists) {
      return res.status(409).json({ success: false, error: 'Email already exists' });
    }
    const passwordHash = await bcrypt.hash(password, 10);
    const user = await db.user.create({
      data: { email, name, passwordHash, role: role || 'ADMIN' }
    });
    const token = generateToken({ id: user.id, email: user.email, role: user.role });
    return res.json({ success: true, data: { token, user: { id: user.id, email: user.email, name: user.name, role: user.role } } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/auth/me
router.get('/me', authMiddleware, async (req: AuthRequest, res) => {
  try {
    const user = await db.user.findUnique({ where: { id: req.user!.id } });
    if (!user) return res.status(404).json({ success: false, error: 'User not found' });
    return res.json({ success: true, data: { id: user.id, email: user.email, name: user.name, role: user.role, avatar: user.avatar } });
  } catch (error: any) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
