
import { Injectable, UnauthorizedException, ConflictException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(dto: { name: string; email: string; password: string; phone?: string; countryCode?: string; role?: string; fcmToken?: string }) {
    // Check if user exists
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existing) throw new ConflictException('Email already registered');

    // Hash password
    const hashedPassword = await bcrypt.hash(dto.password, 12);

    // Determine role: DRIVER or RIDER (default)
    const userRole = dto.role === 'DRIVER' ? 'DRIVER' : 'RIDER';

    // Create user with the specified role
    const user = await this.prisma.user.create({
      data: {
        name: dto.name,
        email: dto.email,
        password: hashedPassword,
        phone: dto.phone,
        countryCode: dto.countryCode,
        role: userRole,
        fcmToken: dto.fcmToken,
      },
    });

    // Create wallet for user
    try {
      await this.prisma.wallet.create({
        data: { userId: user.id, currency: 'USD' },
      });
    } catch (e) {
      console.log('Could not create wallet:', e.message);
    }

    // If registering as driver, create driver profile with auto-verified docs and default vehicle
    if (userRole === 'DRIVER') {
      try {
        const driver = await this.prisma.driver.create({
          data: {
            userId: user.id,
            status: 'OFFLINE',
            isAvailable: true,
            isDocumentsVerified: true, // Auto-verify for development
          },
        });

        // Create default approved vehicle for development
        try {
          await this.prisma.vehicle.create({
            data: {
              driverId: driver.id,
              name: 'Default Vehicle',
              plateNumber: 'TEMP-' + user.id.substring(0, 6).toUpperCase(),
              type: 'SEDAN',
              color: 'White',
              model: 'Standard',
              year: '2024',
              seats: 4,
              isApproved: true, // Auto-approve for development
            },
          });
        } catch (vehicleErr) {
          console.log('Could not create default vehicle:', vehicleErr.message);
        }
      } catch (e) {
        console.log('Could not create driver profile:', e.message);
      }
    }

    // Generate tokens
    const tokens = await this.generateTokens(user.id, user.email, user.role);
    
    // IMPORTANT: isNewUser must be at TOP LEVEL (not inside user) to match Flutter AuthResponse model
    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      isNewUser: true,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        averageRating: user.averageRating || 0,
        totalRides: user.totalRides || 0,
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

    // IMPORTANT: isNewUser must be at TOP LEVEL (not inside user) to match Flutter AuthResponse model
    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      isNewUser: false,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        averageRating: user.averageRating || 0,
        totalRides: user.totalRides || 0,
      },
    };
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
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
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    return { message: 'OTP sent successfully', otp };
  }

  async verifyPhoneOtp(phone: string, otp: string, fcmToken?: string) {
    throw new BadRequestException('Phone OTP login not yet implemented. Use email/password.');
  }

  async forgotPassword(email: string) {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) return { message: 'If email exists, reset link will be sent' };
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
        { secret: process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET, expiresIn: '7d' },
      ),
    ]);

    return { accessToken, refreshToken };
  }
}

