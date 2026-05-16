import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AuthState {
  token: string | null;
  user: { id: string; email: string; name: string; role: string } | null;
  isAuthenticated: boolean;
  login: (token: string, user: any) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      isAuthenticated: false,
      login: (token, user) => set({ token, user, isAuthenticated: true }),
      logout: () => set({ token: null, user: null, isAuthenticated: false }),
    }),
    { name: 'trippo-auth' }
  )
);

const API_BASE = '/api';
const API_PORT = 3001;

export async function apiFetch(path: string, options: RequestInit = {}) {
  const token = useAuthStore.getState().token;
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string> || {}),
  };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const separator = path.includes('?') ? '&' : '?';
  const url = `${API_BASE}${path}${separator}XTransformPort=${API_PORT}`;

  const res = await fetch(url, { ...options, headers });
  const data = await res.json();
  if (!data.success) throw new Error(data.error || 'API Error');
  return data;
}
