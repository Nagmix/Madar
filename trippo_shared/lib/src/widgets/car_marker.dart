import 'package:flutter/material.dart';
import '../theme/madar_theme.dart';

/// Car Marker Widget - Top-down view car icon for driver position on map
///
/// Displays a car icon that rotates based on heading/bearing.
/// When heading is 0°, the car faces north. Rotation is clockwise.
class CarMarker extends StatelessWidget {
  /// Heading in degrees (0 = north, clockwise)
  final double heading;

  /// Marker color (defaults to brand teal)
  final Color? color;

  /// Overall size of the marker widget
  final double size;

  const CarMarker({
    super.key,
    required this.heading,
    this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor = color ?? MadarTheme.primary;

    return Transform.rotate(
      angle: heading * 3.141592653589793 / 180, // degrees to radians
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.directions_car,
            color: markerColor,
            size: size * 0.55,
          ),
        ),
      ),
    );
  }
}

/// Pulsing current-location dot marker (blue pulsing circle)
///
/// Shows the user's real GPS position with a pulsing ring animation.
class CurrentLocationMarker extends StatelessWidget {
  final Animation<double> animation;

  const CurrentLocationMarker({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing ring
            Opacity(
              opacity: (1 - animation.value) * 0.35,
              child: Transform.scale(
                scale: 1.0 + animation.value * 1.0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Middle ring
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
            // Inner dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
