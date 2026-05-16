import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { PrismaService } from '../prisma.service';

/// Trip WebSocket Gateway - Real-time trip updates via Socket.IO
/// Connected to Redis adapter for scaling across multiple instances
@WebSocketGateway({
  cors: { origin: '*' },
  transports: ['websocket'],
})
export class TripGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  constructor(private prisma: PrismaService) {}

  async handleConnection(client: Socket) {
    const userId = client.handshake.auth?.token;
    if (!userId) {
      client.disconnect();
      return;
    }
    // Store socket → userId mapping in Redis
    console.log(`✅ Socket connected: ${client.id} for user: ${userId}`);
  }

  async handleDisconnect(client: Socket) {
    console.log(`❌ Socket disconnected: ${client.id}`);
  }

  @SubscribeMessage('room:join')
  handleJoinRoom(client: Socket, payload: { room: string }) {
    client.join(payload.room);
    console.log(`Socket ${client.id} joined room: ${payload.room}`);
  }

  @SubscribeMessage('room:leave')
  handleLeaveRoom(client: Socket, payload: { room: string }) {
    client.leave(payload.room);
  }

  /// Driver location update - broadcast to trip room
  @SubscribeMessage('driver:location')
  async handleDriverLocation(
    client: Socket,
    payload: { tripId: string; latitude: number; longitude: number; heading?: number; speed?: number },
  ) {
    // Broadcast to all clients in the trip room
    this.server.to(`trip:${payload.tripId}`).emit('trip:driver_location', {
      tripId: payload.tripId,
      latitude: payload.latitude,
      longitude: payload.longitude,
      heading: payload.heading,
      speed: payload.speed,
      timestamp: new Date().toISOString(),
    });

    // Also store in Redis for quick retrieval (with TTL)
    // await this.redis.setex(`driver:loc:${payload.tripId}`, 30, JSON.stringify(payload));
  }

  /// Dispatch response from driver
  @SubscribeMessage('dispatch:response')
  async handleDispatchResponse(
    client: Socket,
    payload: { tripId: string; accepted: boolean; reason?: string },
  ) {
    if (payload.accepted) {
      // Process acceptance via TripService
      this.server.to(`trip:${payload.tripId}`).emit('trip:update', {
        tripId: payload.tripId,
        state: 'DRIVER_ASSIGNED',
      });
    }
  }

  /// Trip cancellation
  @SubscribeMessage('trip:cancel')
  async handleTripCancel(
    client: Socket,
    payload: { tripId: string; reason: string; cancelledBy: string },
  ) {
    this.server.to(`trip:${payload.tripId}`).emit('trip:update', {
      tripId: payload.tripId,
      state: 'TRIP_CANCELLED',
      reason: payload.reason,
      cancelledBy: payload.cancelledBy,
    });
  }

  /// Rating submission
  @SubscribeMessage('trip:rate')
  async handleTripRate(
    client: Socket,
    payload: { tripId: string; rating: number; review?: string },
  ) {
    // Process via TripService
  }

  /// Send dispatch notification to specific driver
  sendDispatchNotification(driverSocketId: string, data: any) {
    this.server.to(driverSocketId).emit('dispatch:notification', data);
  }

  /// Broadcast trip state update to trip room
  broadcastTripUpdate(tripId: string, state: string, data?: any) {
    this.server.to(`trip:${tripId}`).emit('trip:update', {
      tripId,
      state,
      ...data,
      timestamp: new Date().toISOString(),
    });
  }
}
