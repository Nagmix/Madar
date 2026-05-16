import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { WalletStatus, TransactionType, TransactionStatus, WithdrawalStatus } from '@prisma/client';

/// Wallet Service - Manages driver/rider wallets, transactions, withdrawals, and settlements
/// Handles commission deductions, incentive calculations, and settlement processing
@Injectable()
export class WalletService {
  constructor(private prisma: PrismaService) {}

  /// Get wallet balance for the authenticated user
  async getBalance(userId: string) {
    const wallet = await this.prisma.wallet.findUnique({
      where: { userId },
      include: {
        _count: { select: { transactions: true } },
      },
    });

    if (!wallet) throw new NotFoundException('Wallet not found');

    // Also check if user is a driver and return driver wallet if exists
    const driver = await this.prisma.driver.findUnique({ where: { userId } });
    let driverWallet = null;
    if (driver) {
      driverWallet = await this.prisma.wallet.findUnique({
        where: { driverId: driver.id },
      });
    }

    const activeWallet = driverWallet || wallet;

    return {
      id: activeWallet.id,
      availableBalance: activeWallet.availableBalance,
      pendingBalance: activeWallet.pendingBalance,
      totalEarnings: activeWallet.totalEarnings,
      totalWithdrawals: activeWallet.totalWithdrawals,
      totalCommissions: activeWallet.totalCommissions,
      totalIncentives: activeWallet.totalIncentives,
      currency: activeWallet.currency,
      status: activeWallet.status,
    };
  }

  /// Get transaction history with pagination
  async getTransactions(userId: string, page: number = 1, pageSize: number = 20, type?: TransactionType) {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    if (!wallet) throw new NotFoundException('Wallet not found');

    // Also check for driver wallet
    const driver = await this.prisma.driver.findUnique({ where: { userId } });
    let driverWallet = null;
    if (driver) {
      driverWallet = await this.prisma.wallet.findUnique({
        where: { driverId: driver.id },
      });
    }

    const activeWallet = driverWallet || wallet;

    const where = {
      walletId: activeWallet.id,
      ...(type ? { type } : {}),
    };

    const [items, total] = await Promise.all([
      this.prisma.walletTransaction.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.walletTransaction.count({ where }),
    ]);

    return { items, total, page, pageSize };
  }

  /// Request withdrawal
  async requestWithdrawal(userId: string, dto: any) {
    const driver = await this.prisma.driver.findUnique({ where: { userId } });
    if (!driver) throw new ForbiddenException('Only drivers can request withdrawals');

    const wallet = await this.prisma.wallet.findUnique({
      where: { driverId: driver.id },
    });
    if (!wallet) throw new NotFoundException('Driver wallet not found');

    if (wallet.status === WalletStatus.FROZEN) {
      throw new ForbiddenException('Wallet is frozen. Contact support.');
    }

    if (wallet.status === WalletStatus.CLOSED) {
      throw new ForbiddenException('Wallet is closed.');
    }

    // Validate withdrawal amount
    if (dto.amount <= 0) {
      throw new BadRequestException('Withdrawal amount must be positive');
    }

    if (dto.amount > wallet.availableBalance) {
      throw new BadRequestException('Insufficient balance for withdrawal');
    }

    // Check minimum withdrawal amount (configurable)
    const minWithdrawal = 10.0;
    if (dto.amount < minWithdrawal) {
      throw new BadRequestException(`Minimum withdrawal amount is ${minWithdrawal} ${wallet.currency}`);
    }

    // Create withdrawal request
    const withdrawal = await this.prisma.withdrawalRequest.create({
      data: {
        driverId: driver.id,
        walletId: wallet.id,
        amount: dto.amount,
        currency: wallet.currency,
        method: dto.method,
        accountDetails: dto.accountDetails,
        status: WithdrawalStatus.PENDING,
      },
    });

    // Deduct from available balance and move to pending
    await this.prisma.wallet.update({
      where: { id: wallet.id },
      data: {
        availableBalance: { decrement: dto.amount },
        pendingBalance: { increment: dto.amount },
      },
    });

    // Create wallet transaction for withdrawal
    await this.prisma.walletTransaction.create({
      data: {
        walletId: wallet.id,
        driverId: driver.id,
        type: TransactionType.WITHDRAWAL,
        amount: -dto.amount,
        balanceAfter: wallet.availableBalance - dto.amount,
        currency: wallet.currency,
        description: `Withdrawal request via ${dto.method}`,
        referenceId: withdrawal.id,
        status: TransactionStatus.PENDING,
      },
    });

    // TODO: Notify admin for withdrawal approval
    // this.notificationService.notifyAdmin('WITHDRAWAL_REQUEST', { withdrawalId: withdrawal.id, driverId: driver.id, amount: dto.amount });

    return {
      id: withdrawal.id,
      amount: withdrawal.amount,
      currency: withdrawal.currency,
      method: withdrawal.method,
      status: withdrawal.status,
      requestedAt: withdrawal.requestedAt,
    };
  }

  /// Get settlements for the driver
  async getSettlements(userId: string, page: number = 1, pageSize: number = 20) {
    const driver = await this.prisma.driver.findUnique({ where: { userId } });
    if (!driver) throw new ForbiddenException('Only drivers can view settlements');

    const where = { driverId: driver.id };

    const [items, total] = await Promise.all([
      this.prisma.settlement.findMany({
        where,
        orderBy: { startDate: 'desc' },
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
      this.prisma.settlement.count({ where }),
    ]);

    return { items, total, page, pageSize };
  }

  // ==================== Internal Methods (called by other services) ====================

  /// Process trip earning for driver - called when trip is completed
  /// Handles commission deduction and incentive calculation
  async processTripEarning(driverId: string, tripId: string, totalFare: number, currency: string = 'USD') {
    const wallet = await this.prisma.wallet.findUnique({
      where: { driverId },
    });
    if (!wallet) return;

    // Calculate commission (platform fee)
    const commissionRate = await this.getCommissionRate(driverId);
    const commissionAmount = totalFare * commissionRate;
    const driverEarning = totalFare - commissionAmount;

    // Calculate incentive bonus
    const incentiveBonus = await this.calculateIncentiveBonus(driverId, driverEarning);

    // Credit driver earning
    await this.prisma.wallet.update({
      where: { id: wallet.id },
      data: {
        availableBalance: { increment: driverEarning + incentiveBonus },
        totalEarnings: { increment: driverEarning + incentiveBonus },
        totalCommissions: { increment: commissionAmount },
        totalIncentives: { increment: incentiveBonus },
      },
    });

    // Create earning transaction
    const balanceAfterEarning = wallet.availableBalance + driverEarning + incentiveBonus;
    await this.prisma.walletTransaction.create({
      data: {
        walletId: wallet.id,
        driverId,
        type: TransactionType.TRIP_EARNING,
        amount: driverEarning,
        balanceAfter: balanceAfterEarning,
        currency,
        description: `Trip earning for trip ${tripId}`,
        tripId,
        status: TransactionStatus.COMPLETED,
      },
    });

    // Create commission deduction transaction
    if (commissionAmount > 0) {
      await this.prisma.walletTransaction.create({
        data: {
          walletId: wallet.id,
          driverId,
          type: TransactionType.COMMISSION_DEDUCTION,
          amount: -commissionAmount,
          balanceAfter: balanceAfterEarning,
          currency,
          description: `Platform commission (${(commissionRate * 100).toFixed(1)}%) for trip ${tripId}`,
          tripId,
          status: TransactionStatus.COMPLETED,
        },
      });
    }

    // Create incentive transaction
    if (incentiveBonus > 0) {
      await this.prisma.walletTransaction.create({
        data: {
          walletId: wallet.id,
          driverId,
          type: TransactionType.INCENTIVE_BONUS,
          amount: incentiveBonus,
          balanceAfter: balanceAfterEarning,
          currency,
          description: `Incentive bonus for trip ${tripId}`,
          tripId,
          status: TransactionStatus.COMPLETED,
        },
      });
    }

    return {
      totalFare,
      driverEarning,
      commissionAmount,
      commissionRate,
      incentiveBonus,
      netCredited: driverEarning + incentiveBonus,
    };
  }

  /// Get commission rate for a driver (can vary based on driver tier, zone, etc.)
  private async getCommissionRate(driverId: string): Promise<number> {
    // Default commission rate: 20%
    // TODO: Make this configurable per zone/driver tier
    const driver = await this.prisma.driver.findUnique({ where: { id: driverId } });

    // Tier-based commission rates
    if (driver && driver.totalTrips > 500) return 0.15; // 15% for veteran drivers
    if (driver && driver.totalTrips > 100) return 0.18; // 18% for experienced drivers
    return 0.20; // 20% for new drivers
  }

  /// Calculate incentive bonus based on driver performance and active promotions
  private async calculateIncentiveBonus(driverId: string, baseEarning: number): Promise<number> {
    const driver = await this.prisma.driver.findUnique({ where: { id: driverId } });
    if (!driver) return 0;

    let bonus = 0;

    // High acceptance rate bonus
    if (driver.acceptanceRate >= 90) {
      bonus += baseEarning * 0.05; // 5% bonus for acceptance rate >= 90%
    }

    // Low cancellation rate bonus
    if (driver.cancellationRate <= 5) {
      bonus += baseEarning * 0.03; // 3% bonus for cancellation rate <= 5%
    }

    // High rating bonus
    if (driver.averageRating >= 4.8) {
      bonus += baseEarning * 0.02; // 2% bonus for rating >= 4.8
    }

    // TODO: Time-based incentives (peak hours, weekend, holiday bonuses)
    // TODO: Quest/streak incentives (complete N trips for bonus)
    // TODO: Zone-based incentives (pick up from high-demand areas)

    return Math.round(bonus * 100) / 100;
  }

  /// Process withdrawal approval (called by admin)
  async processWithdrawalApproval(withdrawalId: string, approved: boolean, rejectionReason?: string) {
    const withdrawal = await this.prisma.withdrawalRequest.findUnique({
      where: { id: withdrawalId },
    });
    if (!withdrawal) throw new NotFoundException('Withdrawal request not found');

    if (approved) {
      await this.prisma.withdrawalRequest.update({
        where: { id: withdrawalId },
        data: {
          status: WithdrawalStatus.APPROVED,
          processedAt: new Date(),
        },
      });

      // Deduct from pending balance
      await this.prisma.wallet.update({
        where: { id: withdrawal.walletId },
        data: {
          pendingBalance: { decrement: withdrawal.amount },
          totalWithdrawals: { increment: withdrawal.amount },
        },
      });

      // Update transaction status
      await this.prisma.walletTransaction.updateMany({
        where: { referenceId: withdrawalId },
        data: { status: TransactionStatus.COMPLETED },
      });
    } else {
      await this.prisma.withdrawalRequest.update({
        where: { id: withdrawalId },
        data: {
          status: WithdrawalStatus.REJECTED,
          rejectionReason,
          processedAt: new Date(),
        },
      });

      // Refund to available balance
      await this.prisma.wallet.update({
        where: { id: withdrawal.walletId },
        data: {
          availableBalance: { increment: withdrawal.amount },
          pendingBalance: { decrement: withdrawal.amount },
        },
      });

      // Mark transaction as reversed
      await this.prisma.walletTransaction.updateMany({
        where: { referenceId: withdrawalId },
        data: { status: TransactionStatus.REVERSED },
      });
    }
  }
}
