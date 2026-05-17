import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../trip/presentation/notifiers/trip_notifier.dart';

/// ورقة البحث عن سائق - مدار
class RideRequestSheet extends ConsumerWidget {
  const RideRequestSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripProvider);

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 80, height: 80,
          child: Stack(alignment: Alignment.center, children: [
            CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
              value: tripState == TripState.searchingDriver ? null : 0.5,
            ),
            const Icon(Icons.search, size: 32, color: Color(0xFF00C853)),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('جاري البحث عن سائق...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('عادة ما يستغرق أقل من دقيقة', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => ref.read(tripProvider.notifier).cancelTrip(reason: 'إلغاء الراكب'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('إلغاء'),
          ),
        ),
      ]),
    );
  }
}
