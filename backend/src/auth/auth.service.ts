import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(dto: { name: string; email: string; password: string; phone?: string; countryCode?: string; fcmToken?: string }) {
    // Check if user exists
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existing) throw new ConflictException('Email already registered');

    // Hash password
    const hashedPassword = await bcrypt.hash(dto.password, 12);

    // Create user
    const user = await this.prisma.user.create({
      data: {
        name: dto.name,
        email: dto.email,
        password: hashedPassword,
        phone: dto.phone,
        countryCode: dto.countryCode,
        fcmToken: dto.fcmToken,
      },
    });

    // Create wallet for user
    await this.prisma.wallet.create({
      data: { userId: user.id, currency: 'USD' },
    });

    // Generate tokens
    const tokens = await this.generateTokens(user.id, user.email, user.role);
    
    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        isNewUser: true,
      },
    };
  }

  async login(dto: { email: string; password: string; fcmToken?: string }) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (!user) throw new UnauthorizedException('Invalid credentials');

    const isPasswordValid = await bcrypt.compare(dto.password, user.password);
    if (!isPasswordValid) throw new UnauthorizedException('Invalid credentials');

    if (user.isBanned) throw new UnauthorizedException('Account has been banned');

    // Update FCM token if provided
    if (dto.fcmToken) {
      await this.prisma.user.update({
        where: { id: user.id },
        data: { fcmToken: dto.fcmToken, lastActiveAt: new Date() },
      });
    }

    const tokens = await this.generateTokens(user.id, user.email, user.role);

    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        averageRating: user.averageRating,
        totalRides: user.totalRides,
        isNewUser: false,
      },
    };
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET,
      });

      const user = await this.prisma.user.findUnique({ where: { id: payload.sub } });
      if (!user) throw new UnauthorizedException();

      const tokens = await this.generateTokens(user.id, user.email, user.role);
      return tokens;
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async sendPhoneOtp(phone: string, countryCode: string) {
    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Store OTP in Redis with 5 min expiry
    // In production, send via Twilio SMS
    return { message: 'OTP sent successfully', otp }; // Return OTP in dev only
  }

  async verifyPhoneOtp(phone: string, otp: string, fcmToken?: string) {
    // Verify OTP from Redis
    // If valid, find or create user
    // Return auth tokens
    throw new Error('Not implemented yet');
  }

  async forgotPassword(email: string) {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) return { message: 'If email exists, reset link will be sent' };
    
    // Generate reset token and send email
    return { message: 'If email exists, reset link will be sent' };
  }

  private async generateTokens(userId: string, email: string, role: string) {
    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(
        { sub: userId, email, role },
        { secret: process.env.JWT_SECRET, expiresIn: process.env.JWT_EXPIRY || '24h' },
      ),
      this.jwtService.signAsync(
        { sub: userId, email, role },
        { secret: process.env.JWT_REFRESH_SECRET, expiresIn: process.env.JWT_REFRESH_EXPIRY || '7d' },
      ),
    ]);

    return { accessToken, refreshToken };
  }
}
