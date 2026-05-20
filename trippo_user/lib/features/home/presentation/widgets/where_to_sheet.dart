import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../map/presentation/notifiers/map_notifier.dart';

/// ورقة اختيار الوجهة - مدار
/// Updated: Now provides buttons to open location picker screens
class WhereToSheet extends ConsumerStatefulWidget {
  final VoidCallback? onPickupSelect;
  final VoidCallback? onDropoffSelect;

  const WhereToSheet({
    super.key,
    this.onPickupSelect,
    this.onDropoffSelect,
  });

  @override
  ConsumerState<WhereToSheet> createState() => _WhereToSheetState();
}

class _WhereToSheetState extends ConsumerState<WhereToSheet> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isSearching = false;
  List<PlaceResult> _searchResults = [];
  String? _searchError;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _searchPlaces(String query) {
    _debounceTimer?.cancel();
    _searchError = null;
    if (query.length < 2) {
      setState(() { _searchResults = []; _isSearching = false; });
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      try {
        final results = await ref.read(mapLocationProvider.notifier).searchPlaces(query);
        if (mounted) {
          setState(() { _searchResults = results; _isSearching = false; });
        }
      } catch (e) {
        if (mounted) {
          setState(() { _isSearching = false; _searchError = e.toString(); });
        }
      }
    });
  }

  void _selectPlace(PlaceResult place) {
    final mapState = ref.read(mapLocationProvider);
    if (mapState.pickupLocation == null) {
      ref.read(mapLocationProvider.notifier).setPickupLocation(
        LatLng(place.location.latitude, place.location.longitude),
        place.shortAddress,
      );
    } else {
      ref.read(mapLocationProvider.notifier).setDropoffLocation(
        LatLng(place.location.latitude, place.location.longitude),
        place.shortAddress,
      );
    }
    setState(() { _searchResults = []; _searchController.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapLocationProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(MadarTheme.radiusXxl)),
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Column(
        children: [
          // Drag handle
          Center(child: Container(margin: const EdgeInsets.only(top: MadarTheme.space12), width: 40, height: 4, decoration: BoxDecoration(color: MadarTheme.textHint.withOpacity(0.3), borderRadius: BorderRadius.circular(MadarTheme.radiusFull)))),
          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Padding(padding: EdgeInsets.all(14), child: Icon(Icons.search, color: MadarTheme.primary)),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchPlaces,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'إلى أين تريد الذهاب؟',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  if (_isSearching)
                    const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  else if (_searchController.text.isNotEmpty)
                    IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() { _searchResults = []; }); }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Search results
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final place = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.place, color: MadarTheme.primary),
                    title: Text(place.shortAddress, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(place.fullAddress, style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => _selectPlace(place),
                  );
                },
              ),
            )
          else ...[
            // Pickup location button
            if (mapState.pickupAddress == null)
              _buildActionCard(
                icon: Icons.trip_origin,
                iconColor: MadarTheme.mapPickup,
                title: 'تحديد نقطة الانطلاق',
                subtitle: 'اضغط لتحديد موقعك الحالي أو اختيار موقع على الخريطة',
                onTap: widget.onPickupSelect ?? () => _setDefaultPickup(),
              ),

            // Destination button
            if (mapState.pickupAddress != null && mapState.dropoffAddress == null)
              _buildActionCard(
                icon: Icons.location_on,
                iconColor: MadarTheme.mapDropoff,
                title: 'تحديد الوجهة',
                subtitle: 'اختر وجهتك النهائية',
                onTap: widget.onDropoffSelect ?? () {},
              ),

            // Saved locations / recent
            _buildQuickActions(),
          ],
        ],
      ),
    );
  }

  Future<void> _setDefaultPickup() async {
    try {
      await ref.read(mapLocationProvider.notifier).setPickupFromCurrentLocation();
    } catch (e) {
      debugPrint('Error setting pickup: $e');
    }
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('وصول سريع', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildQuickItem(Icons.home, 'المنزل'),
              const SizedBox(width: 10),
              _buildQuickItem(Icons.work, 'العمل'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: MadarTheme.primary, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
