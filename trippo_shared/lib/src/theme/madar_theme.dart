import 'package:flutter/material.dart';

/// Comprehensive design system for the Madar (مدار) ride-hailing app.
///
/// Provides unified colors, typography, spacing, radius, elevation,
/// and both light & dark Material 3 themes used by the user and driver apps.
class MadarTheme {
  MadarTheme._();

  // ────────────────────────────────────────────────────────────────
  // COLOR PALETTE
  // ────────────────────────────────────────────────────────────────

  /// Primary – Emerald/Teal (#00BFA5) – trust, modern
  static const Color primary = Color(0xFF00BFA5);

  /// Primary Dark – (#00897B)
  static const Color primaryDark = Color(0xFF00897B);

  /// Primary Light – (#E0F2F1)
  static const Color primaryLight = Color(0xFFE0F2F1);

  /// Secondary – Deep Indigo (#1A237E)
  static const Color secondary = Color(0xFF1A237E);

  /// Accent – Amber/Gold (#FFB300) – for CTAs, important actions
  static const Color accent = Color(0xFFFFB300);

  /// Accent Dark – (#FF8F00)
  static const Color accentDark = Color(0xFFFF8F00);

  /// Surface – White (#FFFFFF)
  static const Color surface = Color(0xFFFFFFFF);

  /// Background – Off-white (#F8FAFB)
  static const Color background = Color(0xFFF8FAFB);

  /// Dark Surface – (#0D1B2A)
  static const Color darkSurface = Color(0xFF0D1B2A);

  /// Dark Background – (#0A1628)
  static const Color darkBackground = Color(0xFF0A1628);

  /// Text Primary – (#1A1A2E)
  static const Color textPrimary = Color(0xFF1A1A2E);

  /// Text Secondary – (#6B7280)
  static const Color textSecondary = Color(0xFF6B7280);

  /// Text Hint – (#9CA3AF)
  static const Color textHint = Color(0xFF9CA3AF);

  /// Error – (#EF4444)
  static const Color error = Color(0xFFEF4444);

  /// Success – (#10B981)
  static const Color success = Color(0xFF10B981);

  /// Warning – (#F59E0B)
  static const Color warning = Color(0xFFF59E0B);

  // Map-specific colors
  /// Map Pickup pin color – matches primary
  static const Color mapPickup = Color(0xFF00BFA5);

  /// Map Dropoff pin color – red
  static const Color mapDropoff = Color(0xFFEF4444);

  /// Map Route line color – blue
  static const Color mapRoute = Color(0xFF3B82F6);

  /// Map Driver marker color – amber
  static const Color mapDriver = Color(0xFFFFB300);

  // ────────────────────────────────────────────────────────────────
  // TYPOGRAPHY (Cairo font)
  // ────────────────────────────────────────────────────────────────

  static const String fontFamily = 'Cairo';

  static const TextTheme _baseTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w900,
      height: 1.2,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 1.25,
      letterSpacing: -0.3,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
  );

  // ────────────────────────────────────────────────────────────────
  // SPACING
  // ────────────────────────────────────────────────────────────────

  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  /// Convenience list of all spacing values.
  static const List<double> spacings = [
    space4, space8, space12, space16, space20,
    space24, space32, space40, space48, space64,
  ];

  // ────────────────────────────────────────────────────────────────
  // RADIUS
  // ────────────────────────────────────────────────────────────────

  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 28;
  static const double radiusFull = 100;

  // ────────────────────────────────────────────────────────────────
  // ELEVATION
  // ────────────────────────────────────────────────────────────────

  static const double elevationLow = 2;
  static const double elevationMedium = 4;
  static const double elevationHigh = 8;
  static const double elevationUltra = 16;

  // ────────────────────────────────────────────────────────────────
  // LIGHT THEME
  // ────────────────────────────────────────────────────────────────

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        cardColor: surface,
        colorScheme: const ColorScheme.light(
          primary: primary,
          onPrimary: Colors.white,
          primaryContainer: primaryLight,
          onPrimaryContainer: primaryDark,
          secondary: secondary,
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFD1D9FF),
          onSecondaryContainer: secondary,
          tertiary: accent,
          onTertiary: Colors.white,
          error: error,
          onError: Colors.white,
          surface: surface,
          onSurface: textPrimary,
          surfaceContainerHighest: background,
        ),
        textTheme: _baseTextTheme.apply(
          displayColor: textPrimary,
          bodyColor: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: elevationLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: error, width: 1.5),
          ),
          hintStyle: const TextStyle(
            fontFamily: fontFamily,
            color: textHint,
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            fontFamily: fontFamily,
            color: textSecondary,
            fontSize: 14,
          ),
          floatingLabelStyle: const TextStyle(
            fontFamily: fontFamily,
            color: primary,
            fontSize: 12,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: textHint,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          extendedPadding: EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusLg)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFF3F4F6),
          selectedColor: primaryLight,
          labelStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide.none,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(radiusXxl),
            ),
          ),
          showDragHandle: false,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: darkSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          contentTextStyle: const TextStyle(
            fontFamily: fontFamily,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE5E7EB),
          thickness: 1,
          space: 1,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _NoTransitionsBuilder(),
            TargetPlatform.iOS: _NoTransitionsBuilder(),
          },
        ),
      );

  // ────────────────────────────────────────────────────────────────
  // DARK THEME
  // ────────────────────────────────────────────────────────────────

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: primary,
        scaffoldBackgroundColor: darkBackground,
        cardColor: darkSurface,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          onPrimary: Colors.white,
          primaryContainer: primaryDark,
          onPrimaryContainer: primaryLight,
          secondary: Color(0xFF9FA8DA),
          onSecondary: secondary,
          secondaryContainer: secondary,
          onSecondaryContainer: Color(0xFFD1D9FF),
          tertiary: accent,
          onTertiary: Colors.black,
          error: Color(0xFFF87171),
          onError: Colors.black,
          surface: darkSurface,
          onSurface: Colors.white,
          surfaceContainerHighest: darkBackground,
        ),
        textTheme: _baseTextTheme.apply(
          displayColor: Colors.white,
          bodyColor: const Color(0xFFE5E7EB),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: darkSurface,
          elevation: elevationLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(
              fontFamily: fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1B2A3D),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
          ),
          hintStyle: const TextStyle(
            fontFamily: fontFamily,
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            fontFamily: fontFamily,
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
          floatingLabelStyle: const TextStyle(
            fontFamily: fontFamily,
            color: primary,
            fontSize: 12,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: darkSurface,
          selectedItemColor: primary,
          unselectedItemColor: Color(0xFF6B7280),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          extendedPadding: EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusLg)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF1B2A3D),
          selectedColor: primaryDark,
          labelStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          side: BorderSide.none,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(radiusXxl),
            ),
          ),
          showDragHandle: false,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF1B2A3D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          contentTextStyle: const TextStyle(
            fontFamily: fontFamily,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF1E3048),
          thickness: 1,
          space: 1,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _NoTransitionsBuilder(),
            TargetPlatform.iOS: _NoTransitionsBuilder(),
          },
        ),
      );

  // ────────────────────────────────────────────────────────────────
  // UTILITY METHODS
  // ────────────────────────────────────────────────────────────────

  /// Returns a [BoxDecoration] suitable for card-like containers.
  ///
  /// Provides a subtle shadow based on [elevation] and rounded corners
  /// using [radius]. Override [color] to customize the fill.
  static BoxDecoration cardDecoration({
    Color? color,
    double? radius,
    double? elevation,
  }) {
    final double elev = elevation ?? elevationLow;
    final double rad = radius ?? radiusLg;
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(rad),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04 * elev),
          blurRadius: elev * 4,
          offset: Offset(0, elev),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Returns a gradient [BoxDecoration].
  ///
  /// Defaults to a primary → primaryDark gradient with [radius] corners.
  static BoxDecoration gradientDecoration({
    List<Color>? colors,
    double? radius,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors ?? [primary, primaryDark],
        begin: begin ?? Alignment.topLeft,
        end: end ?? Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius ?? radiusLg),
    );
  }

  /// Returns a [BoxShadow] with the given parameters.
  ///
  /// Defaults to a subtle shadow matching the design system elevation.
  static BoxShadow shadow({
    Color? color,
    double? blur,
    Offset? offset,
    double? spread,
  }) {
    return BoxShadow(
      color: color ?? Colors.black.withOpacity(0.08),
      blurRadius: blur ?? 8,
      offset: offset ?? const Offset(0, 2),
      spreadRadius: spread ?? 0,
    );
  }

  /// Returns a [BorderRadius] using the given [radius].
  ///
  /// Defaults to [radiusLg] (16).
  static BorderRadius borderRadius([double? radius]) {
    return BorderRadius.circular(radius ?? radiusLg);
  }
}

// ────────────────────────────────────────────────────────────────
// CUSTOM PAGE TRANSITION BUILDER (no animation)
// ────────────────────────────────────────────────────────────────

/// A page transitions builder that performs no animation.
///
/// This is used so that the app can implement its own custom
/// page transition animations (e.g. [MadarPageTransition]) without
/// Material's default transition interfering.
class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
