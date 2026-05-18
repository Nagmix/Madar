import 'package:flutter/material.dart';
import '../theme/madar_theme.dart';

// ────────────────────────────────────────────────────────────────
// 1. MadarLogo – Animated app logo widget
// ────────────────────────────────────────────────────────────────

/// Displays the Madar (مدار) logo – a rounded container with a
/// local_taxi icon and, optionally, the app name in Arabic below.
class MadarLogo extends StatelessWidget {
  const MadarLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.color,
  });

  final double size;
  final bool showText;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = color ?? MadarTheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Icon(
            Icons.local_taxi,
            size: size * 0.5,
            color: iconColor,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: MadarTheme.space12),
          Text(
            'مدار',
            style: TextStyle(
              fontFamily: MadarTheme.fontFamily,
              fontSize: size * 0.28,
              fontWeight: FontWeight.w900,
              color: iconColor,
            ),
          ),
        ],
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 2. MadarButton – Primary action button
// ────────────────────────────────────────────────────────────────

/// A primary action button that can be solid (gradient) or outlined.
///
/// Supports a loading state that replaces the label with a spinner.
class MadarButton extends StatelessWidget {
  const MadarButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.width,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final Color btnColor = color ?? MadarTheme.primary;

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: _enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: btnColor,
            side: BorderSide(color: btnColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
            ),
            textStyle: TextStyle(
              fontFamily: MadarTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: _buildChild(btnColor, isForeground: true),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [btnColor, color != null ? color! : MadarTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
            child: Center(
              child: _buildChild(Colors.white, isForeground: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(Color fgColor, {required bool isForeground}) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: fgColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: MadarTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: fgColor,
            ),
          ),
        ],
      );
    }
    return Text(
      label,
      style: TextStyle(
        fontFamily: MadarTheme.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: fgColor,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 3. MadarTextField – Styled text input
// ────────────────────────────────────────────────────────────────

/// A styled text field consistent with the Madar design system.
///
/// RTL-aware: defaults to [TextDirection.rtl] for Arabic text.
class MadarTextField extends StatelessWidget {
  const MadarTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textDirection,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textDirection: textDirection,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
      style: TextStyle(
        fontFamily: MadarTheme.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: enabled ? MadarTheme.textPrimary : MadarTheme.textHint,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: MadarTheme.textSecondary, size: 22)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 4. MadarCard – Reusable card container
// ────────────────────────────────────────────────────────────────

/// A card container styled according to the Madar design system.
///
/// Wraps a child with padding, rounded corners and optional shadow.
class MadarCard extends StatelessWidget {
  const MadarCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.elevation,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final double? elevation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(
          horizontal: MadarTheme.space16,
          vertical: MadarTheme.space8,
        ),
        padding: padding ?? const EdgeInsets.all(MadarTheme.space16),
        decoration: MadarTheme.cardDecoration(
          color: color,
          radius: borderRadius,
          elevation: elevation,
        ),
        child: child,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 5. MadarBottomSheet – Styled bottom sheet
// ────────────────────────────────────────────────────────────────

/// Utility for showing a styled modal bottom sheet.
class MadarBottomSheet {
  MadarBottomSheet._();

  /// Shows a modal bottom sheet with rounded top corners and optional
  /// fixed [height].
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double? height,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: height ?? MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(MadarTheme.radiusXxl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: MadarTheme.space12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: MadarTheme.textHint.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(MadarTheme.radiusFull),
                  ),
                ),
              ),
              Flexible(child: child),
            ],
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 6. MadarLoading – Loading indicator
// ────────────────────────────────────────────────────────────────

/// A branded loading indicator with an optional message.
class MadarLoading extends StatelessWidget {
  const MadarLoading({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  });

  final String? message;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? MadarTheme.primary,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: MadarTheme.space16),
          Text(
            message!,
            style: const TextStyle(
              fontFamily: MadarTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: MadarTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 7. MadarAppBar – Styled app bar
// ────────────────────────────────────────────────────────────────

/// A styled app bar consistent with the Madar design system.
///
/// Transparent by default with an optional back button.
class MadarAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MadarAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.showBack = true,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                fontFamily: MadarTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
      actions: actions,
      leading: leading ??
          (showBack && Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 8. MadarStatusBadge – Status indicator badge
// ────────────────────────────────────────────────────────────────

/// A small pill-shaped status badge with an optional icon and label.
class MadarStatusBadge extends StatelessWidget {
  const MadarStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MadarTheme.space12,
        vertical: MadarTheme.space4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(MadarTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: MadarTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 9. MadarGradientButton – Gradient CTA button
// ────────────────────────────────────────────────────────────────

/// A prominent CTA button with a gradient background and shadow.
class MadarGradientButton extends StatelessWidget {
  const MadarGradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.gradientColors,
    this.icon,
    this.width,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color>? gradientColors;
  final IconData? icon;
  final double? width;
  final double height;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = gradientColors ??
        [MadarTheme.accent, MadarTheme.accentDark];

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
        boxShadow: [
          MadarTheme.shadow(
            color: colors.last.withOpacity(0.35),
            blur: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
          child: Center(
            child: _buildChild(),
          ),
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: MadarTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      );
    }
    return Text(
      label,
      style: const TextStyle(
        fontFamily: MadarTheme.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 10. MadarLocationPoint – Pickup/dropoff point indicator
// ────────────────────────────────────────────────────────────────

/// A row widget showing a pickup (green) or dropoff (red) dot with
/// address text.
class MadarLocationPoint extends StatelessWidget {
  const MadarLocationPoint({
    super.key,
    required this.isPickup,
    required this.address,
    this.detail,
  });

  final bool isPickup;
  final String address;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isPickup ? MadarTheme.mapPickup : MadarTheme.mapDropoff;
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(width: MadarTheme.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                style: const TextStyle(
                  fontFamily: MadarTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MadarTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (detail != null)
                Text(
                  detail!,
                  style: const TextStyle(
                    fontFamily: MadarTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: MadarTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 11. MadarSearchingAnimation – Animated searching for driver
// ────────────────────────────────────────────────────────────────

/// A pulsing animation shown while searching for a nearby driver.
class MadarSearchingAnimation extends StatefulWidget {
  const MadarSearchingAnimation({
    super.key,
    this.onCancel,
  });

  final VoidCallback? onCancel;

  @override
  State<MadarSearchingAnimation> createState() =>
      _MadarSearchingAnimationState();
}

class _MadarSearchingAnimationState extends State<MadarSearchingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing circles
        SizedBox(
          width: 160,
          height: 160,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _pulseCircle(
                    _controller.value,
                    opacity: 0.12,
                    scale: 1.0 + _controller.value * 0.6,
                  ),
                  _pulseCircle(
                    (_controller.value - 0.33).clamp(0, 1),
                    opacity: 0.08,
                    scale: 1.0 + (_controller.value - 0.33).clamp(0, 1) * 0.6,
                  ),
                  _pulseCircle(
                    (_controller.value - 0.66).clamp(0, 1),
                    opacity: 0.05,
                    scale: 1.0 + (_controller.value - 0.66).clamp(0, 1) * 0.6,
                  ),
                  // Center icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: MadarTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        MadarTheme.shadow(
                          color: MadarTheme.primary.withOpacity(0.3),
                          blur: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_taxi,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: MadarTheme.space24),
        const Text(
          'جارِ البحث عن سائق...',
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: MadarTheme.textPrimary,
          ),
        ),
        const SizedBox(height: MadarTheme.space8),
        const Text(
          'يرجى الانتظار قليلاً',
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: MadarTheme.textSecondary,
          ),
        ),
        if (widget.onCancel != null) ...[
          const SizedBox(height: MadarTheme.space32),
          MadarButton(
            label: 'إلغاء',
            isOutlined: true,
            onPressed: widget.onCancel,
            width: 200,
          ),
        ],
      ],
    );
  }

  Widget _pulseCircle(double progress, {required double opacity, required double scale}) {
    if (progress <= 0) return const SizedBox.shrink();
    return Opacity(
      opacity: opacity * (1 - progress),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: MadarTheme.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 12. MadarPageTransition – Custom page route transition
// ────────────────────────────────────────────────────────────────

/// A custom page route that slides in from the right with a fade.
///
/// Duration: 300 ms · Curve: [Curves.easeOutCubic].
class MadarPageTransition<T> extends PageRouteBuilder<T> {
  MadarPageTransition({
    required this.child,
    super.settings,
  }) : super(
          pageBuilder: (_, __, ___) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (_, animation, __, widget) {
            final CurvedAnimation curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: curved,
                child: widget,
              ),
            );
          },
        );

  final Widget child;
}

// ────────────────────────────────────────────────────────────────
// 13. MadarEmptyState – Empty state placeholder
// ────────────────────────────────────────────────────────────────

/// A centered placeholder shown when a list or section is empty.
class MadarEmptyState extends StatelessWidget {
  const MadarEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MadarTheme.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: MadarTheme.textHint),
            const SizedBox(height: MadarTheme.space16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: MadarTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: MadarTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: MadarTheme.space8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontFamily: MadarTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: MadarTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: MadarTheme.space24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// 14. MadarPriceTag – Price display widget
// ────────────────────────────────────────────────────────────────

/// Displays a bold price with currency symbol.
class MadarPriceTag extends StatelessWidget {
  const MadarPriceTag({
    super.key,
    required this.amount,
    this.currency = 'ر.ي',
    this.fontSize = 24,
    this.color,
  });

  final double amount;
  final String currency;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2),
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: color ?? MadarTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          currency,
          style: TextStyle(
            fontFamily: MadarTheme.fontFamily,
            fontSize: fontSize * 0.5,
            fontWeight: FontWeight.w600,
            color: color ?? MadarTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
