import { Controller, Get, Post, Query, Body, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { WalletService } from './wallet.service';
import { TransactionType } from '@prisma/client';

@ApiTags('wallet')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@Controller('wallet')
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Get('balance')
  @ApiOperation({ summary: 'Get wallet balance' })
  @ApiResponse({ status: 200, description: 'Wallet balance retrieved' })
  @ApiResponse({ status: 404, description: 'Wallet not found' })
  async getBalance(@Req() req: any) {
    return this.walletService.getBalance(req.user.id);
  }

  @Get('transactions')
  @ApiOperation({ summary: 'Get transaction history with pagination' })
  @ApiResponse({ status: 200, description: 'Transaction history retrieved' })
  async getTransactions(
    @Req() req: any,
    @Query('page') page: string = '1',
    @Query('pageSize') pageSize: string = '20',
    @Query('type') type?: TransactionType,
  ) {
    return this.walletService.getTransactions(req.user.id, parseInt(page), parseInt(pageSize), type);
  }

  @Post('withdraw')
  @ApiOperation({ summary: 'Request withdrawal' })
  @ApiResponse({ status: 201, description: 'Withdrawal request created' })
  @ApiResponse({ status: 400, description: 'Invalid amount or insufficient balance' })
  @ApiResponse({ status: 403, description: 'Only drivers can request withdrawals' })
  async requestWithdrawal(@Req() req: any, @Body() dto: WithdrawalRequestDto) {
    return this.walletService.requestWithdrawal(req.user.id, dto);
  }

  @Get('settlements')
  @ApiOperation({ summary: 'Get settlements' })
  @ApiResponse({ status: 200, description: 'Settlements retrieved' })
  @ApiResponse({ status: 403, description: 'Only drivers can view settlements' })
  async getSettlements(
    @Req() req: any,
    @Query('page') page: string = '1',
    @Query('pageSize') pageSize: string = '20',
  ) {
    return this.walletService.getSettlements(req.user.id, parseInt(page), parseInt(pageSize));
  }
}

// ==================== DTOs ====================

class WithdrawalRequestDto {
  amount: number;
  method: string; // BANK_TRANSFER | MOBILE_WALLET | CASH
  accountDetails: string;
}
