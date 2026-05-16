'use client';

import React, { createContext, useContext, useEffect, useState, useRef } from 'react';

interface DriverLocation {
  lat: number;
  lng: number;
  heading?: number;
  speed?: number;
  timestamp: string;
}

interface RealtimeContextType {
  isConnected: boolean;
  driverLocations: Map<string, DriverLocation>;
  activeTrips: any[];
  stats: any;
}

const RealtimeContext = createContext<RealtimeContextType>({
  isConnected: false,
  driverLocations: new Map(),
  activeTrips: [],
  stats: null,
});

export function useRealtime() {
  return useContext(RealtimeContext);
}

export function RealtimeProvider({ children }: { children: React.ReactNode }) {
  const [isConnected, setIsConnected] = useState(false);
  const [driverLocations, setDriverLocations] = useState<Map<string, DriverLocation>>(new Map());
  const [activeTrips, setActiveTrips] = useState<any[]>([]);
  const [stats, setStats] = useState<any>(null);
  const socketRef = useRef<any>(null);

  useEffect(() => {
    let mounted = true;

    const initSocket = async () => {
      try {
        const socketIO = await import('socket.io-client');
        const io = socketIO.io || socketIO.default || socketIO;
        
        const newSocket = io('/?XTransformPort=3002', {
          transports: ['websocket', 'polling'],
          autoConnect: true,
        });

        newSocket.on('connect', () => {
          if (mounted) {
            setIsConnected(true);
            newSocket.emit('auth:admin', { userId: 'admin' });
          }
        });

        newSocket.on('disconnect', () => {
          if (mounted) setIsConnected(false);
        });

        newSocket.on('admin:driver:location', (data: any) => {
          if (mounted) {
            setDriverLocations(prev => {
              const next = new Map(prev);
              next.set(data.driverId, data);
              return next;
            });
          }
        });

        newSocket.on('admin:driver:status', (data: any) => {
          if (mounted && data.status === 'OFFLINE') {
            setDriverLocations(prev => {
              const next = new Map(prev);
              next.delete(data.driverId);
              return next;
            });
          }
        });

        newSocket.on('admin:stats:update', (data: any) => {
          if (mounted) setStats(data);
        });

        newSocket.on('admin:trip:new', (data: any) => {
          if (mounted) setActiveTrips(prev => [data, ...prev.slice(0, 19)]);
        });

        newSocket.on('admin:trip:update', (data: any) => {
          if (mounted) {
            setActiveTrips(prev => prev.map(t => t.tripId === data.tripId ? { ...t, ...data } : t));
          }
        });

        socketRef.current = newSocket;
      } catch (err) {
        console.error('Failed to initialize socket:', err);
      }
    };

    initSocket();

    return () => {
      mounted = false;
      if (socketRef.current) {
        socketRef.current.disconnect();
      }
    };
  }, []);

  return (
    <RealtimeContext.Provider value={{ isConnected, driverLocations, activeTrips, stats }}>
      {children}
    </RealtimeContext.Provider>
  );
}
