import 'package:flutter/material.dart';
import 'package:trippo_shared/trippo_shared.dart';

/// مدار سائق - نظام التصميم (تطبيق السائق)
class AppTheme {
  AppTheme._();
  
  static ThemeData get lightTheme => MadarTheme.lightTheme;
  static ThemeData get darkTheme => MadarTheme.darkTheme;
  
  // Colors
  static const Color primary = MadarTheme.primary;
  static const Color primaryDark = MadarTheme.primaryDark;
  static const Color primaryLight = MadarTheme.primaryLight;
  static const Color primarySurface = MadarTheme.primaryLight;
  static const Color secondary = MadarTheme.secondary;
  static const Color secondaryDark = Color(0xFF0D47A1);
  static const Color secondaryLight = Color(0xFF64B5F6);
  static const Color accent = MadarTheme.accent;
  static const Color accentLight = Color(0xFFFFAB40);
  static const Color success = MadarTheme.success;
  static const Color warning = MadarTheme.warning;
  static const Color error = MadarTheme.error;
  static const Color info = Color(0xFF2196F3);
  static const Color background = MadarTheme.background;
  static const Color surface = MadarTheme.surface;
  static const Color surfaceDark = MadarTheme.darkSurface;
  static const Color surfaceVariant = Color(0xFFF1F3F4);
  static const Color textPrimary = MadarTheme.textPrimary;
  static const Color textSecondary = MadarTheme.textSecondary;
  static const Color textHint = MadarTheme.textHint;
  static const Color dividerColor = Color(0xFFE8EAED);
  static const Color shadow = Color(0x1A000000);
  static const String fontFamily = MadarTheme.fontFamily;
  
  // Map colors
  static const Color mapPickup = MadarTheme.mapPickup;
  static const Color mapDropoff = MadarTheme.mapDropoff;
  static const Color mapRoute = MadarTheme.mapRoute;
  static const Color mapDriver = MadarTheme.mapDriver;
  
  // Typography - static const
  static const TextStyle heading1 = TextStyle(fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary);
  static const TextStyle heading2 = TextStyle(fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary);
  static const TextStyle heading3 = TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary);
  static const TextStyle bodyLarge = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary);
  static const TextStyle bodyMedium = TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary);
  static const TextStyle bodySmall = TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary);
  static const TextStyle caption = TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w400, color: textHint);
  static const TextStyle button = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5);
  
  // Spacing
  static const double spacing4 = MadarTheme.space4;
  static const double spacing8 = MadarTheme.space8;
  static const double spacing12 = MadarTheme.space12;
  static const double spacing16 = MadarTheme.space16;
  static const double spacing20 = MadarTheme.space20;
  static const double spacing24 = MadarTheme.space24;
  static const double spacing32 = MadarTheme.space32;
  static const double spacing48 = MadarTheme.space48;
  
  // Radius
  static const double radiusSmall = MadarTheme.radiusSm;
  static const double radiusMedium = MadarTheme.radiusMd;
  static const double radiusLarge = MadarTheme.radiusLg;
  static const double radiusXLarge = MadarTheme.radiusXl;
  static const double radiusFull = MadarTheme.radiusFull;
}

