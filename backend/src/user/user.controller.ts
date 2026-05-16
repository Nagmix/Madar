import { Controller, Get, Put, Delete, Body, Query, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { UserService } from './user.service';

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get('profile')
  @ApiOperation({ summary: 'Get user profile' })
  @ApiResponse({ status: 200, description: 'User profile retrieved' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getProfile(@Req() req: any) {
    return this.userService.getProfile(req.user.id);
  }

  @Put('profile')
  @ApiOperation({ summary: 'Update user profile' })
  @ApiResponse({ status: 200, description: 'User profile updated' })
  @ApiResponse({ status: 400, description: 'Email or phone already in use' })
  async updateProfile(@Req() req: any, @Body() dto: UpdateProfileDto) {
    return this.userService.updateProfile(req.user.id, dto);
  }

  @Delete('account')
  @ApiOperation({ summary: 'Delete user account' })
  @ApiResponse({ status: 200, description: 'Account scheduled for deletion' })
  @ApiResponse({ status: 400, description: 'Cannot delete account with active trips or pending withdrawals' })
  async deleteAccount(@Req() req: any, @Body() dto?: DeleteAccountDto) {
    return this.userService.deleteAccount(req.user.id, dto?.reason);
  }
}

// ==================== DTOs ====================

class UpdateProfileDto {
  name?: string;
  email?: string;
  phone?: string;
  countryCode?: string;
  profileImageUrl?: string;
  preferredLanguage?: string;
  preferredCurrency?: string;
}

class DeleteAccountDto {
  reason?: string;
}
