import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../trip/presentation/notifiers/trip_notifier.dart';

/// ورقة تقدم الرحلة - مدار
class TripProgressSheet extends ConsumerWidget {
  const TripProgressSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripProvider);

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildStatusIndicator(tripState),
        const SizedBox(height: 16),
        _buildActionButtons(context, ref, tripState),
      ]),
    );
  }

  Widget _buildStatusIndicator(TripState state) {
    final (String title, String subtitle, IconData icon, Color color) = switch (state) {
      TripState.driverAssigned => ('تم تعيين سائق', 'السائق في طريقه إليك', Icons.person, Colors.blue),
      TripState.driverArriving => ('السائق قادم', 'على وشك الوصول لموقعك', Icons.directions_car, Colors.orange),
      TripState.driverArrived => ('وصل السائق', 'السائق بانتظارك', Icons.location_on, Color(0xFF00C853)),
      TripState.tripStarted => ('الرحلة جارية', 'استمتع برحلتك!', Icons.route, Colors.blue),
      TripState.tripPaused => ('الرحلة متوقفة', 'توقف مؤقت', Icons.pause_circle, Colors.orange),
      TripState.tripResumed => ('تم استئناف الرحلة', 'عدنا للطريق', Icons.play_circle, Color(0xFF00C853)),
      _ => ('', '', Icons.info, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: color)),
          Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ])),
      ]),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, TripState tripState) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => ref.read(tripProvider.notifier).cancelTrip(reason: 'إلغاء الراكب'),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('إلغاء الرحلة'),
      ),
    );
  }
}
