import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

/// User Service - Manages user profiles and account operations
/// Handles profile CRUD, account deletion, and user-related queries
@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  /// Get user profile with related data
  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        driver: {
          select: {
            id: true,
            status: true,
            averageRating: true,
            totalTrips: true,
            isDocumentsVerified: true,
            vehicle: { select: { id: true, name: true, type: true, plateNumber: true } },
          },
        },
        wallet: {
          select: { id: true, availableBalance: true, currency: true },
        },
      },
    });

    if (!user) throw new NotFoundException('User not found');

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      countryCode: user.countryCode,
      profileImageUrl: user.profileImageUrl,
      role: user.role,
      isEmailVerified: user.isEmailVerified,
      isPhoneVerified: user.isPhoneVerified,
      averageRating: user.averageRating,
      totalRides: user.totalRides,
      cancellations: user.cancellations,
      preferredLanguage: user.preferredLanguage,
      preferredCurrency: user.preferredCurrency,
      isActive: user.isActive,
      lastActiveAt: user.lastActiveAt,
      createdAt: user.createdAt,
      driver: user.driver,
      wallet: user.wallet,
    };
  }

  /// Update user profile
  async updateProfile(userId: string, dto: any) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    // Check if email is being changed and if it's already taken
    if (dto.email && dto.email !== user.email) {
      const existingUser = await this.prisma.user.findUnique({ where: { email: dto.email } });
      if (existingUser) throw new BadRequestException('Email already in use');

      // Mark email as unverified when changed
      await this.prisma.user.update({
        where: { id: userId },
        data: { isEmailVerified: false },
      });
    }

    // Check if phone is being changed and if it's already taken
    if (dto.phone && dto.phone !== user.phone) {
      const existingPhone = await this.prisma.user.findFirst({
        where: { phone: dto.phone, id: { not: userId } },
      });
      if (existingPhone) throw new BadRequestException('Phone number already in use');

      // Mark phone as unverified when changed
      await this.prisma.user.update({
        where: { id: userId },
        data: { isPhoneVerified: false },
      });
    }

    // Build update data object
    const updateData: any = {};
    if (dto.name !== undefined) updateData.name = dto.name;
    if (dto.email !== undefined) updateData.email = dto.email;
    if (dto.phone !== undefined) updateData.phone = dto.phone;
    if (dto.countryCode !== undefined) updateData.countryCode = dto.countryCode;
    if (dto.profileImageUrl !== undefined) updateData.profileImageUrl = dto.profileImageUrl;
    if (dto.preferredLanguage !== undefined) updateData.preferredLanguage = dto.preferredLanguage;
    if (dto.preferredCurrency !== undefined) updateData.preferredCurrency = dto.preferredCurrency;
    updateData.lastActiveAt = new Date();

    const updatedUser = await this.prisma.user.update({
      where: { id: userId },
      data: updateData,
      include: {
        driver: {
          select: {
            id: true,
            status: true,
            averageRating: true,
            totalTrips: true,
            vehicle: { select: { id: true, name: true, type: true, plateNumber: true } },
          },
        },
        wallet: {
          select: { id: true, availableBalance: true, currency: true },
        },
      },
    });

    return {
      id: updatedUser.id,
      name: updatedUser.name,
      email: updatedUser.email,
      phone: updatedUser.phone,
      countryCode: updatedUser.countryCode,
      profileImageUrl: updatedUser.profileImageUrl,
      role: updatedUser.role,
      isEmailVerified: updatedUser.isEmailVerified,
      isPhoneVerified: updatedUser.isPhoneVerified,
      preferredLanguage: updatedUser.preferredLanguage,
      preferredCurrency: updatedUser.preferredCurrency,
      driver: updatedUser.driver,
      wallet: updatedUser.wallet,
    };
  }

  /// Delete user account (soft delete + cleanup)
  async deleteAccount(userId: string, reason?: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        driver: {
          include: {
            tripsAsDriver: {
              where: {
                state: { in: ['SEARCHING_DRIVER', 'DRIVER_ASSIGNED', 'DRIVER_ARRIVING', 'DRIVER_ARRIVED', 'TRIP_STARTED', 'TRIP_PAUSED', 'TRIP_RESUMED'] },
              },
            },
          },
        },
        tripsAsRider: {
          where: {
            state: { in: ['SEARCHING_DRIVER', 'DRIVER_ASSIGNED', 'DRIVER_ARRIVING', 'DRIVER_ARRIVED', 'TRIP_STARTED', 'TRIP_PAUSED', 'TRIP_RESUMED'] },
          },
        },
      },
    });

    if (!user) throw new NotFoundException('User not found');

    // Check for active trips
    const activeDriverTrips = user.driver?.tripsAsDriver?.length || 0;
    const activeRiderTrips = user.tripsAsRider?.length || 0;

    if (activeDriverTrips > 0 || activeRiderTrips > 0) {
      throw new BadRequestException(
        'Cannot delete account while you have active trips. Please complete or cancel all trips first.',
      );
    }

    // Check for pending withdrawals (driver)
    if (user.driver) {
      const pendingWithdrawals = await this.prisma.withdrawalRequest.count({
        where: {
          driverId: user.driver.id,
          status: { in: ['PENDING', 'APPROVED', 'PROCESSING'] },
        },
      });

      if (pendingWithdrawals > 0) {
        throw new BadRequestException(
          'Cannot delete account while you have pending withdrawals. Please wait for them to be processed.',
        );
      }
    }

    // Soft delete: mark user as inactive and banned
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        isActive: false,
        isBanned: true,
        email: `deleted_${userId}_${Date.now()}@trippo.deleted`,
        phone: null,
        fcmToken: null,
        name: 'Deleted User',
        profileImageUrl: null,
        lastActiveAt: new Date(),
      },
    });

    // If driver, set offline
    if (user.driver) {
      await this.prisma.driver.update({
        where: { id: user.driver.id },
        data: {
          status: 'OFFLINE',
          isAvailable: false,
        },
      });
    }

    // Deactivate all device tokens
    await this.prisma.deviceToken.updateMany({
      where: { userId },
      data: { isActive: false },
    });

    // Freeze wallet
    await this.prisma.wallet.updateMany({
      where: { userId },
      data: { status: 'CLOSED' },
    });

    // TODO: Schedule permanent data deletion after retention period (e.g., 30 days)
    // TODO: Send account deletion confirmation email
    // TODO: Log deletion for audit trail

    return {
      success: true,
      message: 'Account has been scheduled for deletion',
      deletionScheduledAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 days
    };
  }
}
