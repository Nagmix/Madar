'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useAuthStore, apiFetch } from '@/lib/auth';
import { RealtimeProvider, useRealtime } from '@/lib/realtime';

// ============================================
// ICONS (inline SVG to avoid dependency issues)
// ============================================
const Icons = {
  Dashboard: () => <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect width="7" height="9" x="3" y="3" rx="1"/><rect width="7" height="5" x="14" y="3" rx="1"/><rect width="7" height="9" x="14" y="12" rx="1"/><rect width="7" height="5" x="3" y="16" rx="1"/></svg>,
  Drivers: () => <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path d="M9 17h6"/><circle cx="17" cy="17" r="2"/></svg>,
  Riders: () => <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>,
  Trips: () => <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9,22 9,12 15,12 15,22"/></svg>,
  Wallet: () => <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 12V7H5a2 2 0 0 1 0-4h14v4"/><path d="M3 5v14a2 2 0 0 0 2 2h16v-5"/><path d="M18 12a2 2 0 0 0 0 4h4v-4Z"/></svg>,
  Pricing: () => <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="12" x2="12" y1="2" y2="22"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>,
  Shield: () => <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="m9 12 2 2 4-4"/></svg>,
  Settings: () => <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/><circle cx="12" cy="12" r="3"/></svg>,
  Bell: () => <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></svg>,
  Map: () => <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="1 6 1 22 8 18 16 22 23 18 23 2 16 6 8 2 1 6"/><line x1="8" x2="8" y1="2" y2="18"/><line x1="16" x2="16" y1="6" y2="22"/></svg>,
  Logout: () => <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16,17 21,12 16,7"/><line x1="21" x2="9" y1="12" y2="12"/></svg>,
  Refresh: () => <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 12a9 9 0 0 0-9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path d="M3 3v5h5"/><path d="M3 12a9 9 0 0 0 9 9 9.75 9.75 0 0 0 6.74-2.74L21 16"/><path d="M16 16h5v5"/></svg>,
  Search: () => <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>,
  Eye: () => <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>,
  X: () => <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>,
  ChevronDown: () => <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m6 9 6 6 6-6"/></svg>,
  Check: () => <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>,
  AlertTriangle: () => <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><path d="M12 9v4"/><path d="M12 17h.01"/></svg>,
  TrendingUp: () => <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/><polyline points="16 7 22 7 22 13"/></svg>,
};

// ============================================
// HELPER FUNCTIONS
// ============================================
const statusColors: Record<string, string> = {
  ONLINE: 'bg-emerald-500', OFFLINE: 'bg-gray-400', ON_TRIP: 'bg-blue-500', BUSY: 'bg-amber-500',
  SUSPENDED: 'bg-red-500', BANNED: 'bg-red-700', PENDING_APPROVAL: 'bg-yellow-500', PENDING_DOCUMENTS: 'bg-orange-500',
  ACTIVE: 'bg-emerald-500', PENDING_VERIFICATION: 'bg-yellow-500',
  SEARCHING_DRIVER: 'bg-yellow-500', DRIVER_ASSIGNED: 'bg-blue-500', DRIVER_ARRIVING: 'bg-blue-600',
  DRIVER_ARRIVED: 'bg-indigo-500', TRIP_STARTED: 'bg-emerald-500', TRIP_PAUSED: 'bg-amber-500',
  TRIP_RESUMED: 'bg-emerald-500', TRIP_COMPLETED: 'bg-green-600', PAYMENT_PENDING: 'bg-orange-500',
  PAYMENT_COMPLETED: 'bg-green-700', TRIP_CANCELLED: 'bg-red-500', TRIP_EXPIRED: 'bg-gray-500',
};

const statusLabels: Record<string, string> = {
  ONLINE: 'متصل', OFFLINE: 'غير متصل', ON_TRIP: 'في رحلة', BUSY: 'مشغول',
  SUSPENDED: 'معلق', BANNED: 'محظور', PENDING_APPROVAL: 'بانتظار الموافقة', PENDING_DOCUMENTS: 'بانتظار المستندات',
  ACTIVE: 'نشط', PENDING_VERIFICATION: 'بانتظار التحقق',
  SEARCHING_DRIVER: 'بحث عن سائق', DRIVER_ASSIGNED: 'تم تعيين سائق', DRIVER_ARRIVING: 'السائق في الطريق',
  DRIVER_ARRIVED: 'السائق وصل', TRIP_STARTED: 'الرحلة بدأت', TRIP_PAUSED: 'الرحلة متوقفة',
  TRIP_RESUMED: 'استئناف الرحلة', TRIP_COMPLETED: 'مكتملة', PAYMENT_PENDING: 'بانتظار الدفع',
  PAYMENT_COMPLETED: 'تم الدفع', TRIP_CANCELLED: 'ملغاة', TRIP_EXPIRED: 'منتهية الصلاحية',
  LOW: 'منخفض', MEDIUM: 'متوسط', HIGH: 'عالي', CRITICAL: 'حرج',
  OPEN: 'مفتوح', INVESTIGATING: 'قيد التحقيق', CONFIRMED: 'مؤكد', FALSE_POSITIVE: 'خطأ', RESOLVED: 'تم الحل',
};

function Badge({ status, size = 'sm' }: { status: string; size?: 'sm' | 'md' }) {
  const color = statusColors[status] || 'bg-gray-400';
  const label = statusLabels[status] || status;
  return (
    <span className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium text-white ${color} ${size === 'md' ? 'px-3 py-1 text-sm' : ''}`}>
      <span className="h-1.5 w-1.5 rounded-full bg-white/70" />
      {label}
    </span>
  );
}

function formatCurrency(amount: number) {
  return `${amount.toFixed(2)} ر.س`;
}

function formatDate(date: string | Date) {
  return new Date(date).toLocaleDateString('ar-SA', { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
}

// ============================================
// LOGIN PAGE
// ============================================
function LoginPage() {
  const [email, setEmail] = useState('admin@trippo.com');
  const [password, setPassword] = useState('admin123');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const login = useAuthStore(s => s.login);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const data = await apiFetch('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      });
      login(data.data.token, data.data.user);
    } catch (err: any) {
      setError(err.message);
    }
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900" dir="rtl">
      <div className="w-full max-w-md p-8">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-emerald-600 mb-4">
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2"><path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path d="M9 17h6"/><circle cx="17" cy="17" r="2"/></svg>
          </div>
          <h1 className="text-3xl font-bold text-white">Trippo</h1>
          <p className="text-slate-400 mt-2">لوحة تحكم منصة التوصيل</p>
        </div>

        <div className="bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl p-6 shadow-2xl">
          <form onSubmit={handleLogin} className="space-y-4">
            {error && <div className="bg-red-500/20 border border-red-500/30 rounded-lg p-3 text-red-300 text-sm">{error}</div>}
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1.5">البريد الإلكتروني</label>
              <input type="email" value={email} onChange={e => setEmail(e.target.value)} className="w-full rounded-lg border border-white/10 bg-white/5 px-4 py-2.5 text-white placeholder-slate-500 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none" required />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-1.5">كلمة المرور</label>
              <input type="password" value={password} onChange={e => setPassword(e.target.value)} className="w-full rounded-lg border border-white/10 bg-white/5 px-4 py-2.5 text-white placeholder-slate-500 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 outline-none" required />
            </div>
            <button type="submit" disabled={loading} className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-medium py-2.5 rounded-lg transition-colors disabled:opacity-50">
              {loading ? 'جاري الدخول...' : 'تسجيل الدخول'}
            </button>
          </form>
          <div className="mt-4 text-center text-xs text-slate-500">
            admin@trippo.com / admin123
          </div>
        </div>
      </div>
    </div>
  );
}

// ============================================
// SIDEBAR
// ============================================
type Page = 'dashboard' | 'drivers' | 'riders' | 'trips' | 'wallets' | 'pricing' | 'fraud' | 'settings' | 'map';

const navItems: { id: Page; label: string; icon: React.FC }[] = [
  { id: 'dashboard', label: 'لوحة التحكم', icon: Icons.Dashboard },
  { id: 'map', label: 'الخريطة المباشرة', icon: Icons.Map },
  { id: 'drivers', label: 'السائقون', icon: Icons.Drivers },
  { id: 'riders', label: 'الركاب', icon: Icons.Riders },
  { id: 'trips', label: 'الرحلات', icon: Icons.Trips },
  { id: 'wallets', label: 'المحافظ والمالية', icon: Icons.Wallet },
  { id: 'pricing', label: 'التسعير', icon: Icons.Pricing },
  { id: 'fraud', label: 'مكافحة الاحتيال', icon: Icons.Shield },
  { id: 'settings', label: 'الإعدادات', icon: Icons.Settings },
];

function Sidebar({ currentPage, onNavigate }: { currentPage: Page; onNavigate: (p: Page) => void }) {
  const logout = useAuthStore(s => s.logout);
  const user = useAuthStore(s => s.user);
  const { isConnected } = useRealtime();

  return (
    <aside className="w-64 bg-slate-900 border-l border-slate-800 flex flex-col h-screen sticky top-0" dir="rtl">
      <div className="p-4 border-b border-slate-800">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-emerald-600 flex items-center justify-center">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2"><path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><circle cx="17" cy="17" r="2"/></svg>
          </div>
          <div>
            <h2 className="text-white font-bold text-lg">Trippo</h2>
            <div className="flex items-center gap-1.5 text-xs text-slate-400">
              <span className={`h-2 w-2 rounded-full ${isConnected ? 'bg-emerald-500' : 'bg-red-500'}`} />
              {isConnected ? 'متصل مباشر' : 'غير متصل'}
            </div>
          </div>
        </div>
      </div>

      <nav className="flex-1 p-3 space-y-1 overflow-y-auto">
        {navItems.map(item => (
          <button key={item.id} onClick={() => onNavigate(item.id)}
            className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-colors ${currentPage === item.id ? 'bg-emerald-600/20 text-emerald-400 font-medium' : 'text-slate-400 hover:bg-white/5 hover:text-white'}`}>
            <item.icon />
            {item.label}
          </button>
        ))}
      </nav>

      <div className="p-3 border-t border-slate-800">
        <div className="flex items-center gap-3 px-3 py-2 mb-2">
          <div className="w-8 h-8 rounded-full bg-emerald-600/20 flex items-center justify-center text-emerald-400 text-sm font-bold">
            {user?.name?.[0] || 'A'}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm text-white truncate">{user?.name}</p>
            <p className="text-xs text-slate-500 truncate">{user?.role}</p>
          </div>
        </div>
        <button onClick={logout} className="w-full flex items-center gap-3 px-3 py-2 rounded-lg text-sm text-red-400 hover:bg-red-500/10 transition-colors">
          <Icons.Logout />
          تسجيل الخروج
        </button>
      </div>
    </aside>
  );
}

// ============================================
// DASHBOARD PAGE
// ============================================
function DashboardPage() {
  const [stats, setStats] = useState<any>(null);
  const [revenueChart, setRevenueChart] = useState<any[]>([]);
  const [recentTrips, setRecentTrips] = useState<any[]>([]);
  const [tripsByStatus, setTripsByStatus] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const rtStats = useRealtime().stats;

  const loadData = useCallback(async () => {
    try {
      const [s, rc, rt, ts] = await Promise.all([
        apiFetch('/dashboard/stats'),
        apiFetch('/dashboard/revenue-chart'),
        apiFetch('/dashboard/recent-trips'),
        apiFetch('/dashboard/trips-by-status'),
      ]);
      setStats(s.data);
      setRevenueChart(rc.data);
      setRecentTrips(rt.data);
      setTripsByStatus(ts.data);
    } catch (e) { console.error(e); }
    setLoading(false);
  }, []);

  // eslint-disable-next-line react-hooks/set-state-in-effect
  useEffect(() => { loadData(); }, [loadData]);

  const displayStats = rtStats ? { ...stats, ...rtStats } : stats;

  const statCards = displayStats ? [
    { label: 'إجمالي الركاب', value: displayStats.totalRiders, icon: '👥', color: 'from-blue-500 to-blue-600' },
    { label: 'إجمالي السائقين', value: displayStats.totalDrivers, icon: '🚗', color: 'from-emerald-500 to-emerald-600' },
    { label: 'سائقون متصلون', value: displayStats.onlineDrivers, icon: '📍', color: 'from-teal-500 to-teal-600' },
    { label: 'رحلات نشطة', value: displayStats.activeTrips, icon: '🚀', color: 'from-amber-500 to-amber-600' },
    { label: 'إجمالي الإيرادات', value: formatCurrency(displayStats.totalRevenue), icon: '💰', color: 'from-purple-500 to-purple-600' },
    { label: 'رحلات اليوم', value: displayStats.todayTrips, icon: '📊', color: 'from-rose-500 to-rose-600' },
    { label: 'إيرادات اليوم', value: formatCurrency(displayStats.todayRevenue), icon: '💵', color: 'from-cyan-500 to-cyan-600' },
    { label: 'تنبيهات احتيال', value: displayStats.fraudAlerts, icon: '🛡️', color: 'from-red-500 to-red-600' },
  ] : [];

  const maxRevenue = Math.max(...revenueChart.map(d => d.revenue), 1);

  return (
    <div className="space-y-6" dir="rtl">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">لوحة التحكم</h1>
          <p className="text-slate-400 text-sm mt-1">نظرة عامة على المنصة</p>
        </div>
        <button onClick={loadData} className="flex items-center gap-2 px-4 py-2 rounded-lg bg-white/5 text-slate-300 hover:bg-white/10 transition-colors text-sm">
          <Icons.Refresh /> تحديث
        </button>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(8)].map((_, i) => <div key={i} className="h-28 rounded-xl bg-slate-800/50 animate-pulse" />)}
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {statCards.map((card, i) => (
            <div key={i} className={`relative overflow-hidden rounded-xl bg-gradient-to-br ${card.color} p-5 text-white shadow-lg`}>
              <div className="text-3xl mb-2">{card.icon}</div>
              <p className="text-white/70 text-sm">{card.label}</p>
              <p className="text-2xl font-bold mt-1">{card.value}</p>
            </div>
          ))}
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Revenue Chart */}
        <div className="bg-slate-800/50 rounded-xl border border-slate-700/50 p-5">
          <h3 className="text-white font-semibold mb-4">الإيرادات (آخر 7 أيام)</h3>
          <div className="flex items-end gap-2 h-48">
            {revenueChart.map((d, i) => (
              <div key={i} className="flex-1 flex flex-col items-center gap-1">
                <span className="text-xs text-slate-400">{formatCurrency(d.revenue)}</span>
                <div className="w-full bg-emerald-500/30 rounded-t-md relative" style={{ height: `${(d.revenue / maxRevenue) * 100}%`, minHeight: d.revenue > 0 ? '8px' : '2px' }}>
                  <div className="absolute inset-0 bg-emerald-500 rounded-t-md opacity-80" />
                </div>
                <span className="text-xs text-slate-500">{d.date?.slice(5)}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Trips by Status */}
        <div className="bg-slate-800/50 rounded-xl border border-slate-700/50 p-5">
          <h3 className="text-white font-semibold mb-4">الرحلات حسب الحالة</h3>
          <div className="space-y-3">
            {tripsByStatus && Object.entries(tripsByStatus).map(([status, count]: [string, any]) => (
              <div key={status} className="flex items-center gap-3">
                <Badge status={status} size="md" />
                <div className="flex-1 h-2 bg-slate-700 rounded-full overflow-hidden">
                  <div className={`h-full rounded-full ${statusColors[status] || 'bg-gray-500'}`} style={{ width: `${Math.min((count as number / (stats?.totalTrips || 1)) * 100, 100)}%` }} />
                </div>
                <span className="text-slate-300 text-sm font-medium w-8 text-left">{count as number}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Recent Trips */}
      <div className="bg-slate-800/50 rounded-xl border border-slate-700/50 p-5">
        <h3 className="text-white font-semibold mb-4">آخر الرحلات</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead><tr className="text-slate-400 border-b border-slate-700/50">
              <th className="text-right py-2 px-3">رقم الرحلة</th>
              <th className="text-right py-2 px-3">الراكب</th>
              <th className="text-right py-2 px-3">السائق</th>
              <th className="text-right py-2 px-3">من</th>
              <th className="text-right py-2 px-3">إلى</th>
              <th className="text-right py-2 px-3">التكلفة</th>
              <th className="text-right py-2 px-3">الحالة</th>
              <th className="text-right py-2 px-3">التاريخ</th>
            </tr></thead>
            <tbody>
              {recentTrips.map((trip: any) => (
                <tr key={trip.id} className="border-b border-slate-700/30 hover:bg-white/5">
                  <td className="py-2 px-3 text-emerald-400 font-mono text-xs">{trip.tripNumber}</td>
                  <td className="py-2 px-3 text-white">{trip.rider?.name}</td>
                  <td className="py-2 px-3 text-white">{trip.driver?.name || '—'}</td>
                  <td className="py-2 px-3 text-slate-300 max-w-[120px] truncate">{trip.originAddress}</td>
                  <td className="py-2 px-3 text-slate-300 max-w-[120px] truncate">{trip.destinationAddress}</td>
                  <td className="py-2 px-3 text-emerald-400 font-medium">{formatCurrency(trip.totalFare)}</td>
                  <td className="py-2 px-3"><Badge status={trip.status} /></td>
                  <td className="py-2 px-3 text-slate-400 text-xs">{formatDate(trip.requestedAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

// ============================================
// DRIVERS PAGE
// ============================================
function DriversPage() {
  const [drivers, setDrivers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [page, setPage] = useState(1);
  const [pagination, setPagination] = useState({ page: 1, limit: 20, total: 0, pages: 0 });
  const [selectedDriver, setSelectedDriver] = useState<any>(null);

  const loadDrivers = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({ page: String(page), limit: '20' });
      if (search) params.set('search', search);
      if (statusFilter) params.set('status', statusFilter);
      const data = await apiFetch(`/drivers?${params}`);
      setDrivers(data.data);
      setPagination(data.pagination);
    } catch (e) { console.error(e); }
    setLoading(false);
  }, [page, search, statusFilter]);

  // eslint-disable-next-line react-hooks/set-state-in-effect
  useEffect(() => { loadDrivers(); }, [loadDrivers]);

  const updateDriverStatus = async (driverId: string, status: string) => {
    try {
      await apiFetch(`/drivers/${driverId}/status`, { method: 'PUT', body: JSON.stringify({ status }) });
      loadDrivers();
      setSelectedDriver(null);
    } catch (e) { console.error(e); }
  };

  return (
    <div className="space-y-6" dir="rtl">
      <div className="flex items-center justify-between">
        <div><h1 className="text-2xl font-bold text-white">إدارة السائقين</h1><p className="text-slate-400 text-sm mt-1">إدارة وتتبع السائقين</p></div>
      </div>

      <div className="flex gap-3 flex-wrap">
        <div className="relative flex-1 min-w-[200px]">
          <span className="absolute right-3 top-2.5 text-slate-400"><Icons.Search /></span>
          <input type="text" placeholder="بحث بالاسم أو الهاتف..." value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} className="w-full rounded-lg border border-slate-700 bg-slate-800/50 pr-9 pl-4 py-2 text-white text-sm focus:border-emerald-500 outline-none" />
        </div>
        <select value={statusFilter} onChange={e => { setStatusFilter(e.target.value); setPage(1); }} className="rounded-lg border border-slate-700 bg-slate-800/50 px-4 py-2 text-white text-sm focus:border-emerald-500 outline-none">
          <option value="">كل الحالات</option>
          <option value="ONLINE">متصل</option><option value="OFFLINE">غير متصل</option><option value="ON_TRIP">في رحلة</option>
          <option value="SUSPENDED">معلق</option><option value="PENDING_APPROVAL">بانتظار الموافقة</option>
        </select>
      </div>

      <div className="bg-slate-800/50 rounded-xl border border-slate-700/50 overflow-hidden">
        <table className="w-full text-sm">
          <thead><tr className="text-slate-400 border-b border-slate-700/50 bg-slate-800/80">
            <th className="text-right py-3 px-4">السائق</th>
            <th className="text-right py-3 px-4">الهاتف</th>
            <th className="text-right py-3 px-4">المركبة</th>
            <th className="text-right py-3 px-4">التقييم</th>
            <th className="text-right py-3 px-4">الرحلات</th>
            <th className="text-right py-3 px-4">نسبة القبول</th>
            <th className="text-right py-3 px-4">الحالة</th>
            <th className="text-right py-3 px-4">إجراءات</th>
          </tr></thead>
          <tbody>
            {loading ? <tr><td colSpan={8} className="text-center py-8 text-slate-400">جاري التحميل...</td></tr> :
              drivers.map((d: any) => (
                <tr key={d.id} className="border-b border-slate-700/30 hover:bg-white/5 transition-colors">
                  <td className="py-3 px-4">
                    <div className="flex items-center gap-3">
                      <div className="w-9 h-9 rounded-full bg-emerald-600/20 flex items-center justify-center text-emerald-400 font-bold text-sm">{d.name[0]}</div>
                      <div><p className="text-white font-medium">{d.name}</p><p className="text-slate-400 text-xs">{d.email}</p></div>
                    </div>
                  </td>
                  <td className="py-3 px-4 text-slate-300">{d.phone}</td>
                  <td className="py-3 px-4 text-slate-300">{d.vehicle ? `${d.vehicle.make} ${d.vehicle.model}` : '—'}</td>
                  <td className="py-3 px-4 text-amber-400">⭐ {d.rating.toFixed(1)}</td>
                  <td className="py-3 px-4 text-white">{d.totalTrips}</td>
                  <td className="py-3 px-4 text-white">{d.acceptanceRate.toFixed(0)}%</td>
                  <td className="py-3 px-4"><Badge status={d.status} /></td>
                  <td className="py-3 px-4">
                    <button onClick={() => setSelectedDriver(d)} className="text-emerald-400 hover:text-emerald-300 text-xs font-medium">عرض التفاصيل</button>
                  </td>
                </tr>
              ))}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {pagination.pages > 1 && (
        <div className="flex items-center justify-center gap-2">
          <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="px-3 py-1 rounded bg-slate-700 text-white text-sm disabled:opacity-50">السابق</button>
          <span className="text-slate-400 text-sm">{page} / {pagination.pages}</span>
          <button onClick={() => setPage(p => Math.min(pagination.pages, p + 1))} disabled={page === pagination.pages} className="px-3 py-1 rounded bg-slate-700 text-white text-sm disabled:opacity-50">التالي</button>
        </div>
      )}

      {/* Driver Detail Modal */}
      {selectedDriver && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={() => setSelectedDriver(null)}>
          <div className="bg-slate-800 rounded-2xl border border-slate-700 p-6 max-w-lg w-full max-h-[80vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-bold text-white">تفاصيل السائق</h3>
              <button onClick={() => setSelectedDriver(null)} className="text-slate-400 hover:text-white"><Icons.X /></button>
            </div>
            <div className="space-y-4">
              <div className="flex items-center gap-4">
                <div className="w-16 h-16 rounded-2xl bg-emerald-600/20 flex items-center justify-center text-emerald-400 font-bold text-2xl">{selectedDriver.name[0]}</div>
                <div><p className="text-white font-bold text-lg">{selectedDriver.name}</p><p className="text-slate-400 text-sm">{selectedDriver.email}</p><Badge status={selectedDriver.status} size="md" /></div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="bg-slate-700/50 rounded-lg p-3"><p className="text-slate-400 text-xs">الهاتف</p><p className="text-white text-sm mt-1">{selectedDriver.phone}</p></div>
                <div className="bg-slate-700/50 rounded-lg p-3"><p className="text-slate-400 text-xs">التقييم</p><p className="text-amber-400 text-sm mt-1">⭐ {selectedDriver.rating.toFixed(1)}</p></div>
                <div className="bg-slate-700/50 rounded-lg p-3"><p className="text-slate-400 text-xs">إجمالي الرحلات</p><p className="text-white text-sm mt-1">{selectedDriver.totalTrips}</p></div>
                <div className="bg-slate-700/50 rounded-lg p-3"><p className="text-slate-400 text-xs">ساعات العمل</p><p className="text-white text-sm mt-1">{selectedDriver.totalOnlineHours} ساعة</p></div>
              </div>
              {selectedDriver.vehicle && (
                <div className="bg-slate-700/50 rounded-lg p-3">
                  <p className="text-slate-400 text-xs mb-2">المركبة</p>
                  <p className="text-white text-sm">{selectedDriver.vehicle.make} {selectedDriver.vehicle.model} ({selectedDriver.vehicle.year})</p>
                  <p className="text-slate-400 text-xs mt-1">{selectedDriver.vehicle.color} | {selectedDriver.vehicle.plateNumber}</p>
                </div>
              )}
              <div className="flex gap-2 pt-2">
                {selectedDriver.status === 'PENDING_APPROVAL' && (
                  <>
                    <button onClick={() => updateDriverStatus(selectedDriver.id, 'ONLINE')} className="flex-1 bg-emerald-600 hover:bg-emerald-700 text-white py-2 rounded-lg text-sm font-medium">موافقة</button>
                    <button onClick={() => updateDriverStatus(selectedDriver.id, 'SUSPENDED')} className="flex-1 bg-red-600 hover:bg-red-700 text-white py-2 rounded-lg text-sm font-medium">رفض</button>
                  </>
                )}
                {selectedDriver.status === 'ONLINE' && <button onClick={() => updateDriverStatus(selectedDriver.id, 'SUSPENDED')} className="w-full bg-red-600 hover:bg-red-700 text-white py-2 rounded-lg text-sm font-medium">تعليق</button>}
                {selectedDriver.status === 'SUSPENDED' && <button onClick={() => updateDriverStatus(selectedDriver.id, 'ONLINE')} className="w-full bg-emerald-600 hover:bg-emerald-700 text-white py-2 rounded-lg text-sm font-medium">إعادة تفعيل</button>}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ============================================
// RIDERS PAGE
// ============================================
function RidersPage() {
  const [riders, setRiders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [pagination, setPagination] = useState({ page: 1, limit: 20, total: 0, pages: 0 });

  const loadRiders = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({ page: String(page), limit: '20' });
      if (search) params.set('search', search);
      const data = await apiFetch(`/riders?${params}`);
      setRiders(data.data);
      setPagination(data.pagination);
    } catch (e) { console.error(e); }
    setLoading(false);
  }, [page, search]);

  // eslint-disable-next-line react-hooks/set-state-in-effect
  useEffect(() => { loadRiders(); }, [loadRiders]);

  return (
    <div className="space-y-6" dir="rtl">
      <div className="flex items-center justify-between">
        <div><h1 className="text-2xl font-bold text-white">إدارة الركاب</h1><p className="text-slate-400 text-sm mt-1">عرض وإدارة حسابات الركاب</p></div>
      </div>
      <div className="flex gap-3">
        <div className="relative flex-1 min-w-[200px]">
          <span className="absolute right-3 top-2.5 text-slate-400"><Icons.Search /></span>
          <input type="text" placeholder="بحث..." value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} className="w-full rounded-lg border border-slate-700 bg-slate-800/50 pr-9 pl-4 py-2 text-white text-sm focus:border-emerald-500 outline-none" />
        </div>
      </div>
      <div className="bg-slate-800/50 rounded-xl border border-slate-700/50 overflow-hidden">
        <table className="w-full text-sm">
          <thead><tr className="text-slate-400 border-b border-slate-700/50 bg-slate-800/80">
            <th className="text-right py-3 px-4">الراكب</th><th className="text-right py-3 px-4">الهاتف</th><th className="text-right py-3 px-4">التقييم</th><th className="text-right py-3 px-4">الرحلات</th><th className="text-right py-3 px-4">الرصيد</th><th className="text-right py-3 px-4">الحالة</th>
          </tr></thead>
          <tbody>
            {loading ? <tr><td colSpan={6} className="text-center py-8 text-slate-400">جاري التحميل...</td></tr> :
              riders.map((r: any) => (
                <tr key={r.id} className="border-b border-slate-700/30 hover:bg-white/5">
                  <td className="py-3 px-4">
                    <div className="flex items-center gap-3">
                      <div className="w-9 h-9 rounded-full bg-blue-600/20 flex items-center justify-center text-blue-400 font-bold text-sm">{r.name[0]}</div>
                      <div><p className="text-white font-medium">{r.name}</p><p className="text-slate-400 text-xs">{r.email}</p></div>
                    </div>
                  </td>
                  <td className="py-3 px-4 text-slate-300">{r.phone}</td>
                  <td className="py-3 px-4 text-amber-400">⭐ {r.rating.toFixed(1)}</td>
                  <td className="py-3 px-4 text-white">{r.totalRides}</td>
                  <td className="py-3 px-4 text-emerald-400">{r.wallet ? formatCurrency(r.wallet.balance) : '—'}</td>
                  <td className="py-3 px-4"><Badge status={r.status} /></td>
                </tr>
              ))}
          </tbody>
        </table>
      </div>
      {pagination.pages > 1 && (
        <div className="flex items-center justify-center gap-2">
          <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="px-3 py-1 rounded bg-slate-700 text-white text-sm disabled:opacity-50">السابق</button>
          <span className="text-slate-400 text-sm">{page} / {pagination.pages}</span>
          <button onClick={() => setPage(p => Math.min(pagination.pages, p + 1))} disabled={page === pagination.pages} className="px-3 py-1 rounded bg-slate-700 text-white text-sm disabled:opacity-50">التالي</button>
        </div>
      )}
    </div>
  );
}

// ============================================
// TRIPS PAGE
// ============================================
function TripsPage() {
  const [trips, setTrips] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('');
  const [page, setPage] = useState(1);
  const [pagination, setPagination] = useState({ page: 1, limit: 20, total: 0, pages: 0 });
  const [selectedTrip, setSelectedTrip] = useState<any>(null);

  const loadTrips = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({ page: String(page), limit: '20' });
      if (statusFilter) params.set('status', statusFilter);
      const data = await apiFetch(`/trips?${params}`);
      setTrips(data.data);
      setPagination(data.pagination);
    } catch (e) { console.error(e); }
    setLoading(false);
  }, [page, statusFilter]);

  // eslint-disable-next-line react-hooks/set-state-in-effect
  useEffect(() => { loadTrips(); }, [loadTrips]);

  const viewTrip = async (tripId: string) => {
    try {
      const data = await apiFetch(`/trips/${tripId}`);
      setSelectedTrip(data.data);
    } catch (e) { console.error(e); }
  };

  return (
    <div className="space-y-6" dir="rtl">
      <div className="flex items-center justify-between">
        <div><h1 className="text-2xl font-bold text-white">إدارة الرحلات</h1><p className="text-slate-400 text-sm mt-1">تتبع وإدارة جميع الرحلات</p></div>
      </div>
      <div className="flex gap-3 flex-wrap">
        <select value={statusFilter} onChange={e => { setStatusFilter(e.target.value); setPage(1); }} className="rounded-lg border border-slate-700 bg-slate-800/50 px-4 py-2 text-white text-sm focus:border-emerald-500 outline-none">
          <option value="">كل الحالات</option>
          <option value="SEARCHING_DRIVER">بحث عن سائق</option><option value="DRIVER_ASSIGNED">تم التعيين</option><option value="TRIP_STARTED">قيد التنفيذ</option>
          <option value="TRIP_COMPLETED">مكتملة</option><option value="TRIP_CANCELLED">ملغاة</option>
        </select>
      </div>
      <div className="bg-slate-800/50 rounded-xl border border-slate-700/50 overflow-hidden">
        <table className="w-full text-sm">
          <thead><tr className="text-slate-400 border-b border-slate-700/50 bg-slate-800/80">
            <th className="text-right py-3 px-4">رقم الرحلة</th><th className="text-right py-3 px-4">الراكب</th><th className="text-right py-3 px-4">السائق</th><th className="text-right py-3 px-4">من → إلى</th><th className="text-right py-3 px-4">المسافة</th><th className="text-right py-3 px-4">التكلفة</th><th className="text-right py-3 px-4">الحالة</th><th className="text-right py-3 px-4">التاريخ</th>
          </tr></thead>
          <tbody>
            {loading ? <tr><td colSpan={8} className="text-center py-8 text-slate-400">جاري التحميل...</td></tr> :
              trips.map((t: any) => (
                <tr key={t.id} className="border-b border-slate-700/30 hover:bg-white/5 cursor-pointer" onClick={() => viewTrip(t.id)}>
                  <td className="py-3 px-4 text-emerald-400 font-mono text-xs">{t.tripNumber}</td>
                  <td className="py-3 px-4 text-white">{t.rider?.name}</td>
                  <td className="py-3 px-4 text-white">{t.driver?.name || '—'}</td>
                  <td className="py-3 px-4"><p className="text-slate-300 truncate max-w-[150px]">{t.originAddress}</p><p className="text-slate-500 truncate max-w-[150px] text-xs">→ {t.destinationAddress}</p></td>
                  <td className="py-3 px-4 text-white">{t.distanceMeters ? `${(t.distanceMeters / 1000).toFixed(1)} كم` : '—'}</td>
                  <td className="py-3 px-4 text-emerald-400 font-medium">{formatCurrency(t.totalFare)}</td>
                  <td className="py-3 px-4"><Badge status={t.status} /></td>
                  <td className="py-3 px-4 text-slate-400 text-xs">{formatDate(t.requestedAt)}</td>
                </tr>
              ))}
          </tbody>
        </table>
      </div>
      {pagination.pages > 1 && (
        <div className="flex items-center justify-center gap-2">
          <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="px-3 py-1 rounded bg-slate-700 text-white text-sm disabled:opacity-50">السابق</button>
          <span className="text-slate-400 text-sm">{page} / {pagination.pages}</span>
          <button onClick={() => setPage(p => Math.min(pagination.pages, p + 1))} disabled={page === pagination.pages} className="px-3 py-1 rounded bg-slate-700 text-white text-sm disabled:opacity-50">التالي</button>
        </div>
      )}

      {/* Trip Detail Modal */}
      {selectedTrip && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={() => setSelectedTrip(null)}>
          <div className="bg-slate-800 rounded-2xl border border-slate-700 p-6 max-w-2xl w-full max-h-[80vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-bold text-white">رحلة {selectedTrip.tripNumber}</h3>
              <button onClick={() => setSelectedTrip(null)} className="text-slate-400 hover:text-white"><Icons.X /></button>
            </div>
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <div className="bg-slate-700/50 rounded-lg p-3"><p className="text-slate-400 text-xs">الراكب</p><p className="text-white text-sm mt-1">{selectedTrip.rider?.name}</p></div>
                <div className="bg-slate-700/50 rounded-lg p-3"><p className="text-slate-400 text-xs">السائق</p><p className="text-white text-sm mt-1">{selectedTrip.driver?.name || 'لم يتم التعيين'}</p></div>
                <div className="bg-slate-700/50 rounded-lg p-3"><p className="text-slate-400 text-xs">من</p><p className="text-white text-sm mt-1">{selectedTrip.originAddress}</p></div>
                <div className="bg-slate-700/50 rounded-lg p-3"><p className="text-slate-400 text-xs">إلى</p><p className="text-white text-sm mt-1">{selectedTrip.destinationAddress}</p></div>
              </div>
              <div className="bg-slate-700/50 rounded-lg p-3">
                <p className="text-slate-400 text-xs mb-2">تفاصيل التكلفة</p>
                <div className="grid grid-cols-3 gap-2 text-sm">
                  <div><span className="text-slate-400">الأساسي:</span> <span className="text-white">{formatCurrency(selectedTrip.baseFare)}</span></div>
                  <div><span className="text-slate-400">المسافة:</span> <span className="text-white">{formatCurrency(selectedTrip.distanceFare)}</span></div>
                  <div><span className="text-slate-400">الوقت:</span> <span className="text-white">{formatCurrency(selectedTrip.timeFare)}</span></div>
                  <div><span className="text-slate-400">الانتظار:</span> <span className="text-white">{formatCurrency(selectedTrip.waitingFee)}</span></div>
                  <div><span className="text-slate-400">الذروة:</span> <span className="text-white">x{selectedTrip.surgeMultiplier}</span></div>
                  <div><span className="text-slate-400 font-bold">الإجمالي:</span> <span className="text-emerald-400 font-bold">{formatCurrency(selectedTrip.totalFare)}</span></div>
                </div>
              </div>
              {/* Trip Events Timeline */}
              {selectedTrip.tripEvents && (
                <div className="bg-slate-700/50 rounded-lg p-3">
                  <p className="text-slate-400 text-xs mb-3">سجل الأحداث</p>
                  <div className="space-y-2">
                    {selectedTrip.tripEvents.map((event: any, i: number) => (
                      <div key={i} className="flex items-center gap-3 text-sm">
                        <div className="w-2 h-2 rounded-full bg-emerald-500" />
                        <span className="text-slate-300"><Badge status={event.status} /></span>
                        <span className="text-slate-500 text-xs">{event.actor}</span>
                        <span className="text-slate-500 text-xs mr-auto">{formatDate(event.createdAt)}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ============================================
// WALLETS PAGE
// ============================================
function WalletsPage() {
  const [tab, setTab] = useState<'wallets' | 'transactions' | 'settlements'>('wallets');
  const [wallets, setWallets] = useState<any[]>([]);
  const [transactions, setTransactions] = useState<any[]>([]);
  const [settlements, setSettlements] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      try {
        if (tab === 'wallets') { const d = await apiFetch('/wallets'); setWallets(d.data); }
        else if (tab === 'transactions') { const d = await apiFetch('/wallets/transactions/list'); setTransactions(d.data); }
        else { const d = await apiFetch('/wallets/settlements/list'); setSettlements(d.data); }
      } catch (e) { console.error(e); }
      setLoading(false);
    };
    loadData();
  }, [tab]);

  return (
    <div className="space-y-6" dir="rtl">
      <div><h1 className="text-2xl font-bold text-white">المحافظ والمالية</h1><p className="text-slate-400 text-sm mt-1">إدارة المحافظ والمعاملات والتسويات</p></div>
      <div className="flex gap-2">
        {[{ id: 'wallets', label: 'المحافظ' }, { id: 'transactions', label: 'المعاملات' }, { id: 'settlements', label: 'التسويات' }].map(t => (
          <button key={t.id} onClick={() => setTab(t.id as any)} className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${tab === t.id ? 'bg-emerald-600 text-white' : 'bg-slate-700/50 text-slate-300 hover:bg-slate-700'}`}>{t.label}</button>
        ))}
      </div>

      {tab === 'wallets' && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {wallets.map((w: any) => (
            <div key={w.id} className="bg-slate-800/50 rounded-xl border border-slate-700/50 p-5">
              <div className="flex items-center justify-between mb-3">
                <span className={`px-2 py-1 rounded text-xs ${w.ownerType === 'driver' ? 'bg-emerald-500/20 text-emerald-400' : 'bg-blue-500/20 text-blue-400'}`}>{w.ownerType === 'driver' ? 'سائق' : 'راكب'}</span>
                <span className="text-slate-400 text-xs">{w.currency}</span>
              </div>
              <p className="text-2xl font-bold text-white">{formatCurrency(w.balance)}</p>
              <div className="mt-3 space-y-1">
                {w.transactions?.slice(0, 3).map((t: any) => (
                  <div key={t.id} className="flex items-center justify-between text-xs">
                    <span className="text-slate-400">{t.description}</span>
                    <span className={t.type === 'CREDIT' ? 'text-emerald-400' : 'text-red-400'}>{t.type === 'CREDIT' ? '+' : '-'}{formatCurrency(t.amount)}</span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {tab === 'transactions' && (
        <div className="bg-slate-800/50 rounded-xl border border-slate-700/50 overflow-hidden">
          <table className="w-full text-sm">
            <thead><tr className="text-slate-400 border-b border-slate-700/50 bg-slate-800/80">
              <th className="text-right py-3 px-4">النوع</th><th className="text-right py-3 px-4">المبلغ</th><th className="text-right py-3 px-4">الوصف</th><th className="text-right py-3 px-4">الحالة</th><th className="text-right py-3 px-4">التاريخ</th>
            </tr></thead>
            <tbody>
              {transactions.map((t: any) => (
                <tr key={t.id} className="border-b border-slate-700/30 hover:bg-white/5">
                  <td className="py-3 px-4"><span className={`px-2 py-1 rounded text-xs ${t.type === 'CREDIT' ? 'bg-emerald-500/20 text-emerald-400' : t.type === 'DEBIT' ? 'bg-red-500/20 text-red-400' : 'bg-blue-500/20 text-blue-400'}`}>{t.type}</span></td>
                  <td className={`py-3 px-4 font-medium ${t.type === 'CREDIT' ? 'text-emerald-400' : 'text-red-400'}`}>{t.type === 'CREDIT' ? '+' : '-'}{formatCurrency(t.amount)}</td>
                  <td className="py-3 px-4 text-slate-300">{t.description || '—'}</td>
                  <td className="py-3 px-4 text-slate-300">{t.status}</td>
                  <td className="py-3 px-4 text-slate-400 text-xs">{formatDate(t.createdAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {tab === 'settlements' && (
        <div className="bg-slate-800/50 rounded-xl border border-slate-700/50 overflow-hidden">
          <table className="w-full text-sm">
            <thead><tr className="text-slate-400 border-b border-slate-700/50 bg-slate-800/80">
              <th className="text-right py-3 px-4">السائق</th><th className="text-right py-3 px-4">الفترة</th><th className="text-right py-3 px-4">رحلات</th><th className="text-right py-3 px-4">الأرباح</th><th className="text-right py-3 px-4">العمولة</th><th className="text-right py-3 px-4">الصافي</th><th className="text-right py-3 px-4">الحالة</th>
            </tr></thead>
            <tbody>
              {settlements.map((s: any) => (
                <tr key={s.id} className="border-b border-slate-700/30 hover:bg-white/5">
                  <td className="py-3 px-4 text-white">{s.driver?.name}</td>
                  <td className="py-3 px-4 text-slate-300 text-xs">{formatDate(s.periodStart)} - {formatDate(s.periodEnd)}</td>
                  <td className="py-3 px-4 text-white">{s.totalTrips}</td>
                  <td className="py-3 px-4 text-emerald-400">{formatCurrency(s.totalEarnings)}</td>
                  <td className="py-3 px-4 text-red-400">{formatCurrency(s.commission)}</td>
                  <td className="py-3 px-4 text-white font-bold">{formatCurrency(s.netAmount)}</td>
                  <td className="py-3 px-4"><Badge status={s.status} /></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

// ============================================
// PRICING PAGE
// ============================================
function PricingPage() {
  const [tiers, setTiers] = useState<any[]>([]);
  const [surgeRules, setSurgeRules] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      try {
        const [t, s] = await Promise.all([apiFetch('/pricing/tiers'), apiFetch('/pricing/surge')]);
        setTiers(t.data);
        setSurgeRules(s.data);
      } catch (e) { console.error(e); }
      setLoading(false);
    };
    loadData();
  }, []);

  return (
    <div className="space-y-6" dir="rtl">
      <div><h1 className="text-2xl font-bold text-white">نظام التسعير</h1><p className="text-slate-400 text-sm mt-1">إدارة أسعار الرحلات والذروة</p></div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {tiers.map((t: any) => (
          <div key={t.id} className="bg-slate-800/50 rounded-xl border border-slate-700/50 p-5">
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-white font-bold">{t.name}</h3>
              <Badge status={t.vehicleType} />
            </div>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between"><span className="text-slate-400">الأجرة الأساسية</span><span className="text-white">{formatCurrency(t.baseFare)}</span></div>
              <div className="flex justify-between"><span className="text-slate-400">لكل كم</span><span className="text-white">{formatCurrency(t.perKmRate)}</span></div>
              <div className="flex justify-between"><span className="text-slate-400">لكل دقيقة</span><span className="text-white">{formatCurrency(t.perMinuteRate)}</span></div>
              <div className="flex justify-between"><span className="text-slate-400">الحد الأدنى</span><span className="text-white">{formatCurrency(t.minimumFare)}</span></div>
              <div className="flex justify-between"><span className="text-slate-400">رسوم الإلغاء</span><span className="text-white">{formatCurrency(t.cancellationFee)}</span></div>
              <div className="flex justify-between"><span className="text-slate-400">انتظار/دقيقة</span><span className="text-white">{formatCurrency(t.waitingFeePerMinute)}</span></div>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-slate-800/50 rounded-xl border border-slate-700/50 p-5">
        <h3 className="text-white font-semibold mb-4">قواعد تسعير الذروة</h3>
        <div className="space-y-3">
          {surgeRules.map((s: any) => (
            <div key={s.id} className="flex items-center gap-4 bg-slate-700/30 rounded-lg p-4">
              <div className="w-12 h-12 rounded-xl bg-amber-500/20 flex items-center justify-center text-amber-400 font-bold text-lg">x{s.multiplier}</div>
              <div className="flex-1">
                <p className="text-white font-medium">{s.name}</p>
                <p className="text-slate-400 text-sm">{s.startTime} - {s.endTime}</p>
              </div>
              <Badge status={s.isActive ? 'ACTIVE' : 'OFFLINE'} />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ============================================
// FRAUD PAGE
// ============================================
function FraudPage() {
  const [alerts, setAlerts] = useState<any[]>([]);
  const [stats, setFraudStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const [a, s] = await Promise.all([apiFetch('/fraud/alerts'), apiFetch('/fraud/stats')]);
      setAlerts(a.data);
      setFraudStats(s.data);
    } catch (e) { console.error(e); }
    setLoading(false);
  }, []);

  // eslint-disable-next-line react-hooks/set-state-in-effect
  useEffect(() => { loadData(); }, [loadData]);

  const resolveAlert = async (id: string, status: string) => {
    try {
      await apiFetch(`/fraud/alerts/${id}`, { method: 'PUT', body: JSON.stringify({ status, resolution: `Admin ${status}` }) });
      loadData();
    } catch (e) { console.error(e); }
  };

  return (
    <div className="space-y-6" dir="rtl">
      <div><h1 className="text-2xl font-bold text-white">مكافحة الاحتيال</h1><p className="text-slate-400 text-sm mt-1">كشف وإدارة حالات الاحتيال</p></div>

      {stats && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div className="bg-red-500/10 border border-red-500/20 rounded-xl p-4"><p className="text-red-400 text-sm">إجمالي التنبيهات</p><p className="text-2xl font-bold text-white mt-1">{stats.total}</p></div>
          <div className="bg-amber-500/10 border border-amber-500/20 rounded-xl p-4"><p className="text-amber-400 text-sm">مفتوحة</p><p className="text-2xl font-bold text-white mt-1">{stats.open}</p></div>
          <div className="bg-red-600/10 border border-red-600/20 rounded-xl p-4"><p className="text-red-500 text-sm">حرجة</p><p className="text-2xl font-bold text-white mt-1">{stats.critical}</p></div>
          <div className="bg-purple-500/10 border border-purple-500/20 rounded-xl p-4"><p className="text-purple-400 text-sm">تلاعب GPS</p><p className="text-2xl font-bold text-white mt-1">{stats.gpsSpoofing}</p></div>
        </div>
      )}

      <div className="space-y-3">
        {alerts.map((alert: any) => (
          <div key={alert.id} className="bg-slate-800/50 rounded-xl border border-slate-700/50 p-5">
            <div className="flex items-start gap-4">
              <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${alert.severity === 'CRITICAL' ? 'bg-red-500/20' : alert.severity === 'HIGH' ? 'bg-amber-500/20' : 'bg-yellow-500/20'}`}>
                <Icons.AlertTriangle />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <Badge status={alert.severity} size="md" />
                  <Badge status={alert.status} size="md" />
                  <span className="text-slate-400 text-xs">{alert.type}</span>
                </div>
                <p className="text-white text-sm">{alert.description}</p>
                <p className="text-slate-500 text-xs mt-1">{formatDate(alert.createdAt)}</p>
              </div>
              {alert.status === 'OPEN' && (
                <div className="flex gap-2">
                  <button onClick={() => resolveAlert(alert.id, 'CONFIRMED')} className="px-3 py-1 rounded bg-red-600 text-white text-xs">تأكيد</button>
                  <button onClick={() => resolveAlert(alert.id, 'FALSE_POSITIVE')} className="px-3 py-1 rounded bg-slate-600 text-white text-xs">خطأ</button>
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ============================================
// MAP PAGE (Live Driver Tracking)
// ============================================
function MapPage() {
  const { driverLocations, isConnected } = useRealtime();
  const [drivers, setDrivers] = useState<any[]>([]);

  useEffect(() => {
    const loadDrivers = async () => {
      try {
        const data = await apiFetch('/drivers/online');
        setDrivers(data.data);
      } catch (e) { console.error(e); }
    };
    loadDrivers();
    const interval = setInterval(loadDrivers, 30000);
    return () => clearInterval(interval);
  }, []);

  const onlineDrivers = drivers.map(d => {
    const loc = driverLocations.get(d.id);
    const latestLoc = d.driverLocations?.[0];
    return {
      ...d,
      currentLat: loc?.lat || latestLoc?.latitude,
      currentLng: loc?.lng || latestLoc?.longitude,
    };
  }).filter(d => d.currentLat && d.currentLng);

  return (
    <div className="space-y-6" dir="rtl">
      <div className="flex items-center justify-between">
        <div><h1 className="text-2xl font-bold text-white">الخريطة المباشرة</h1><p className="text-slate-400 text-sm mt-1">تتبع السائقين والرحلات في الوقت الفعلي</p></div>
        <div className="flex items-center gap-2">
          <span className={`h-2.5 w-2.5 rounded-full ${isConnected ? 'bg-emerald-500 animate-pulse' : 'bg-red-500'}`} />
          <span className="text-slate-300 text-sm">{isConnected ? 'متصل مباشر' : 'غير متصل'}</span>
        </div>
      </div>

      {/* Simulated Map View */}
      <div className="relative bg-slate-900 rounded-xl border border-slate-700/50 overflow-hidden" style={{ height: '500px' }}>
        <div className="absolute inset-0 bg-gradient-to-br from-slate-800 via-slate-900 to-slate-800 opacity-90">
          {/* Grid lines for map effect */}
          <svg className="w-full h-full opacity-10">
            <defs><pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse"><path d="M 40 0 L 0 0 0 40" fill="none" stroke="white" strokeWidth="0.5"/></pattern></defs>
            <rect width="100%" height="100%" fill="url(#grid)" />
          </svg>
        </div>

        {/* Driver markers */}
        {onlineDrivers.map((d: any) => {
          const x = ((d.currentLng - 46.65) / 0.1) * 100;
          const y = ((24.75 - d.currentLat) / 0.1) * 100;
          if (x < 0 || x > 100 || y < 0 || y > 100) return null;
          return (
            <div key={d.id} className="absolute group" style={{ left: `${x}%`, top: `${y}%`, transform: 'translate(-50%, -50%)' }}>
              <div className="relative">
                <div className="w-8 h-8 rounded-full bg-emerald-500 flex items-center justify-center text-white text-xs font-bold shadow-lg shadow-emerald-500/30 cursor-pointer hover:scale-110 transition-transform">
                  🚗
                </div>
                <div className="absolute -bottom-1 left-1/2 transform -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-emerald-500" />
              </div>
              <div className="hidden group-hover:block absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 bg-slate-800 border border-slate-700 rounded-lg p-2 min-w-[140px] z-10">
                <p className="text-white text-xs font-medium">{d.name}</p>
                <p className="text-slate-400 text-xs">{d.vehicle?.make} {d.vehicle?.model}</p>
                <p className="text-emerald-400 text-xs">⭐ {d.rating.toFixed(1)}</p>
              </div>
            </div>
          );
        })}

        {/* Legend */}
        <div className="absolute bottom-4 right-4 bg-slate-800/90 border border-slate-700 rounded-lg p-3 backdrop-blur-sm">
          <p className="text-slate-300 text-xs font-medium mb-2">دليل الخريطة</p>
          <div className="space-y-1.5 text-xs">
            <div className="flex items-center gap-2"><span className="w-3 h-3 rounded-full bg-emerald-500" /> سائق متصل</div>
            <div className="flex items-center gap-2"><span className="w-3 h-3 rounded-full bg-blue-500" /> في رحلة</div>
            <div className="flex items-center gap-2"><span className="w-3 h-3 rounded-full bg-amber-500" /> مشغول</div>
          </div>
        </div>

        {/* Stats overlay */}
        <div className="absolute top-4 right-4 bg-slate-800/90 border border-slate-700 rounded-lg p-3 backdrop-blur-sm">
          <p className="text-white font-bold text-lg">{onlineDrivers.length}</p>
          <p className="text-slate-400 text-xs">سائق متصل</p>
        </div>
      </div>

      {/* Online Drivers List */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
        {onlineDrivers.map((d: any) => (
          <div key={d.id} className="bg-slate-800/50 rounded-lg border border-slate-700/50 p-3 flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-emerald-600/20 flex items-center justify-center text-emerald-400 font-bold">{d.name[0]}</div>
            <div className="flex-1 min-w-0">
              <p className="text-white text-sm font-medium truncate">{d.name}</p>
              <p className="text-slate-400 text-xs">{d.vehicle?.make} {d.vehicle?.model} | ⭐ {d.rating.toFixed(1)}</p>
            </div>
            <Badge status={d.status} />
          </div>
        ))}
      </div>
    </div>
  );
}

// ============================================
// SETTINGS PAGE
// ============================================
function SettingsPage() {
  const [configs, setConfigs] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadConfigs = async () => {
      try {
        const data = await apiFetch('/config');
        setConfigs(data.data);
      } catch (e) { console.error(e); }
      setLoading(false);
    };
    loadConfigs();
  }, []);

  const updateConfig = async (key: string, value: string) => {
    try {
      await apiFetch(`/config/${key}`, { method: 'PUT', body: JSON.stringify({ value }) });
      setConfigs(prev => prev.map(c => c.key === key ? { ...c, value } : c));
    } catch (e) { console.error(e); }
  };

  const groups = [...new Set(configs.map(c => c.group).filter(Boolean))];

  return (
    <div className="space-y-6" dir="rtl">
      <div><h1 className="text-2xl font-bold text-white">الإعدادات</h1><p className="text-slate-400 text-sm mt-1">إعدادات النظام والتكوين</p></div>
      {groups.map(group => (
        <div key={group} className="bg-slate-800/50 rounded-xl border border-slate-700/50 p-5">
          <h3 className="text-white font-semibold mb-4 capitalize">{group}</h3>
          <div className="space-y-3">
            {configs.filter(c => c.group === group).map(c => (
              <div key={c.id} className="flex items-center gap-4">
                <div className="flex-1">
                  <p className="text-white text-sm">{c.description || c.key}</p>
                  <p className="text-slate-500 text-xs">{c.key}</p>
                </div>
                <input defaultValue={c.value} onBlur={e => { if (e.target.value !== c.value) updateConfig(c.key, e.target.value); }} className="w-48 rounded-lg border border-slate-700 bg-slate-700/50 px-3 py-1.5 text-white text-sm focus:border-emerald-500 outline-none" />
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

// ============================================
// MAIN APP
// ============================================
export default function Home() {
  const isAuthenticated = useAuthStore(s => s.isAuthenticated);
  const [currentPage, setCurrentPage] = useState<Page>('dashboard');

  if (!isAuthenticated) {
    return <LoginPage />;
  }

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard': return <DashboardPage />;
      case 'drivers': return <DriversPage />;
      case 'riders': return <RidersPage />;
      case 'trips': return <TripsPage />;
      case 'wallets': return <WalletsPage />;
      case 'pricing': return <PricingPage />;
      case 'fraud': return <FraudPage />;
      case 'map': return <MapPage />;
      case 'settings': return <SettingsPage />;
      default: return <DashboardPage />;
    }
  };

  return (
    <RealtimeProvider>
      <div className="flex min-h-screen bg-slate-950">
        <Sidebar currentPage={currentPage} onNavigate={setCurrentPage} />
        <main className="flex-1 p-6 overflow-y-auto max-h-screen">
          {renderPage()}
        </main>
      </div>
    </RealtimeProvider>
  );
}
