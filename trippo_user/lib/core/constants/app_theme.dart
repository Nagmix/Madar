import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// مدار - نظام التصميم الاحترافي
/// Madar - Professional Design System
/// 
/// الألوان مستوحاة من هوية مدار للنقل الذكي
/// الخط: IBM Plex Sans Arabic (عصري وواضح)
/// الاتجاه: من اليمين لليسار (RTL) كافتراضي
class AppTheme {
  AppTheme._();

  // ==================== هوية الألوان ====================

  // اللون الأساسي - أخضر مدار
  static const Color primary = Color(0xFF00C853);
  static const Color primaryDark = Color(0xFF009624);
  static const Color primaryLight = Color(0xFFB9F6CA);
  static const Color primarySurface = Color(0xFFE8F5E9);

  // اللون الثانوي - أزرق داكن
  static const Color secondary = Color(0xFF1565C0);
  static const Color secondaryDark = Color(0xFF0D47A1);
  static const Color secondaryLight = Color(0xFF64B5F6);

  // لون التمييز - برتقالي
  static const Color accent = Color(0xFFFF6D00);
  static const Color accentLight = Color(0xFFFFAB40);

  // ألوان الحالة
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF1744);
  static const Color info = Color(0xFF2196F3);

  // الألوان المحايدة
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFFF1F3F4);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textHint = Color(0xFF9AA0A6);
  static const Color divider = Color(0xFFE8EAED);
  static const Color shadow = Color(0x1A000000);

  // ألوان الخريطة
  static const Color mapPickup = Color(0xFF00C853);
  static const Color mapDropoff = Color(0xFFFF1744);
  static const Color mapRoute = Color(0xFF1565C0);
  static const Color mapDriver = Color(0xFFFF6D00);

  // ==================== الخطوط ====================

  static const String fontFamily = 'MadarFont';

  // ==================== أنماط مختصرة ====================

  static const TextStyle heading1 = TextStyle(fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w800, color: textPrimary);
  static const TextStyle heading2 = TextStyle(fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary);
  static const TextStyle heading3 = TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary);
  static const TextStyle bodyLarge = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary);
  static const TextStyle bodyMedium = TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary);
  static const TextStyle bodySmall = TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary);
  static const TextStyle caption = TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w400, color: textHint);
  static const TextStyle button = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5);


  // ==================== الحشو ====================

  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // ==================== نصف القطر ====================

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull = 100.0;

  // ==================== الثيم الفاتح ====================

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primary,
      primaryContainer: primaryLight,
      secondary: secondary,
      secondaryContainer: secondaryLight,
      error: error,
      surface: surface,
      onSurface: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 1,
      shadowColor: shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      margin: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: textHint, fontFamily: fontFamily),
      labelStyle: const TextStyle(color: textSecondary, fontFamily: fontFamily),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXLarge)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariant,
      selectedColor: primarySurface,
      labelStyle: const TextStyle(fontFamily: fontFamily),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w800, fontSize: 32, color: textPrimary),
      displayMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, fontSize: 28, color: textPrimary),
      displaySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, fontSize: 24, color: textPrimary),
      headlineLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, fontSize: 22, color: textPrimary),
      headlineMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 20, color: textPrimary),
      headlineSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 18, color: textPrimary),
      titleLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 16, color: textPrimary),
      titleMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, fontSize: 14, color: textPrimary),
      titleSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, fontSize: 12, color: textSecondary),
      bodyLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, fontSize: 16, color: textPrimary),
      bodyMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, fontSize: 14, color: textPrimary),
      bodySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, fontSize: 12, color: textSecondary),
      labelLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary),
      labelMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, fontSize: 12, color: textSecondary),
      labelSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, fontSize: 10, color: textHint),
    ),
  );

  // ==================== الثيم الداكن ====================

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: surfaceDark,
    fontFamily: fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      primaryContainer: primaryDark,
      secondary: secondaryLight,
      secondaryContainer: secondary,
      error: error,
      surface: surfaceDark,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF252540),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      margin: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF252540),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Colors.white38, fontFamily: fontFamily),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w800, fontSize: 32, color: Colors.white),
      displayMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, fontSize: 28, color: Colors.white),
      displaySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, fontSize: 24, color: Colors.white),
      headlineLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, fontSize: 22, color: Colors.white),
      headlineMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
      headlineSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
      titleLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
      titleMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white70),
      titleSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, fontSize: 12, color: Colors.white54),
      bodyLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white70),
      bodySmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, fontSize: 12, color: Colors.white54),
      labelLarge: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
      labelMedium: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w500, fontSize: 12, color: Colors.white70),
      labelSmall: TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w400, fontSize: 10, color: Colors.white38),
    ),
  );
}
