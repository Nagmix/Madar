import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../map/presentation/notifiers/map_notifier.dart';
import '../../../trip/presentation/notifiers/trip_notifier.dart';

/// ورقة اختيار الوجهة - مدار
class WhereToSheet extends ConsumerStatefulWidget {
  const WhereToSheet({super.key});

  @override
  ConsumerState<WhereToSheet> createState() => _WhereToSheetState();
}

class _WhereToSheetState extends ConsumerState<WhereToSheet> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isSearching = false;
  List<PlaceResult> _searchResults = [];
  VehicleType _selectedVehicleType = VehicleType.sedan;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _searchPlaces(String query) {
    _debounceTimer?.cancel();
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    // Debounce to respect Nominatim rate limits (1 req/sec)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      try {
        final results =
            await ref.read(mapLocationProvider.notifier).searchPlaces(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  void _selectDestination(PlaceResult place) {
    ref
        .read(mapLocationProvider.notifier)
        .setDropoffLocation(place.location, place.shortAddress);
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapLocationProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MadarTheme.radiusXxl),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // مقبض السحب
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

          // حقل البحث
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Container(
              decoration: BoxDecoration(
                color: MadarTheme.background,
                borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
                border: Border.all(
                  color: MadarTheme.primary.withOpacity(0.1),
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(
                  fontFamily: MadarTheme.fontFamily,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن وجهتك...',
                  hintStyle: const TextStyle(
                    fontFamily: MadarTheme.fontFamily,
                    color: MadarTheme.textHint,
                  ),
                  prefixIcon: const Icon(Icons.search,
                      color: MadarTheme.primary, size: 22),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (val) {
                  _searchPlaces(val);
                  setState(() {});
                },
              ),
            ),
          ),

          // نقاط الانطلاق والوصول
          if (mapState.pickupAddress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildLocationPoints(mapState),
            ),

          // نتائج البحث
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                        color: MadarTheme.primary))
                : _searchResults.isNotEmpty
                    ? ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) =>
                            _buildSearchResultItem(_searchResults[index]),
                      )
                    : _buildSavedPlaces(),
          ),

          // اختيار المركبة وزر الطلب
          if (mapState.dropoffLocation != null) ...[
            _buildVehicleSelection(),
            _buildRequestButton(mapState),
          ],
        ],
      ),
    );
  }

  // ── نقاط الانطلاق والوصول ──
  Widget _buildLocationPoints(MapLocationState mapState) {
    return Container(
      padding: const EdgeInsets.all(MadarTheme.space16),
      decoration: BoxDecoration(
        color: MadarTheme.background,
        borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
      ),
      child: Column(
        children: [
          MadarLocationPoint(
            isPickup: true,
            address: mapState.pickupAddress ?? 'موقعك الحالي',
          ),
          if (mapState.dropoffAddress != null) ...[
            const SizedBox(height: MadarTheme.space12),
            Row(
              children: [
                Expanded(
                  child: MadarLocationPoint(
                    isPickup: false,
                    address: mapState.dropoffAddress!,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      ref.read(mapLocationProvider.notifier).clearDropoff(),
                  child: const Icon(Icons.close,
                      size: 18, color: MadarTheme.textHint),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── عنصر نتيجة البحث ──
  Widget _buildSearchResultItem(PlaceResult place) {
    return InkWell(
      onTap: () => _selectDestination(place),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 4, vertical: MadarTheme.space12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: MadarTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(MadarTheme.radiusMd),
              ),
              child: const Icon(Icons.location_on_outlined,
                  color: MadarTheme.primary, size: 22),
            ),
            const SizedBox(width: MadarTheme.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: MadarTheme.fontFamily,
                      color: MadarTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.fullAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: MadarTheme.textSecondary,
                      fontSize: 12,
                      fontFamily: MadarTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── الأماكن المحفوظة ──
  Widget _buildSavedPlaces() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 56, color: MadarTheme.textHint.withOpacity(0.4)),
          const SizedBox(height: MadarTheme.space16),
          Text(
            'ابحث عن وجهتك',
            style: TextStyle(
              color: MadarTheme.textSecondary,
              fontFamily: MadarTheme.fontFamily,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ── اختيار نوع المركبة ──
  Widget _buildVehicleSelection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر نوع المركبة',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              fontFamily: MadarTheme.fontFamily,
              color: MadarTheme.textPrimary,
            ),
          ),
          const SizedBox(height: MadarTheme.space12),
          Row(
            children: [
              _vehicleOption(Icons.directions_car, 'سيدان', VehicleType.sedan,
                  '800 ر.ي'),
              const SizedBox(width: 8),
              _vehicleOption(
                  Icons.local_taxi, 'مريح', VehicleType.suv, '1200 ر.ي'),
              const SizedBox(width: 8),
              _vehicleOption(Icons.airport_shuttle, 'فان', VehicleType.van,
                  '1500 ر.ي'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vehicleOption(
      IconData icon, String name, VehicleType type, String price) {
    final selected = _selectedVehicleType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedVehicleType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? MadarTheme.primary.withOpacity(0.08)
                : MadarTheme.background,
            borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
            border: Border.all(
              color: selected ? MadarTheme.primary : MadarTheme.textHint.withOpacity(0.2),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? MadarTheme.primary : MadarTheme.textSecondary,
                  size: 26),
              const SizedBox(height: 6),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  fontFamily: MadarTheme.fontFamily,
                  color: selected ? MadarTheme.primary : MadarTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                price,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: MadarTheme.fontFamily,
                  color: selected ? MadarTheme.primary : MadarTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── زر طلب الرحلة ──
  Widget _buildRequestButton(MapLocationState mapState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: MadarGradientButton(
        label: 'طلب رحلة',
        onPressed: mapState.dropoffLocation != null
            ? () {
                ref.read(tripProvider.notifier).createTrip(CreateTripRequest(
                      pickupLatitude: mapState.pickupLocation!.latitude,
                      pickupLongitude: mapState.pickupLocation!.longitude,
                      pickupAddress: mapState.pickupAddress ?? '',
                      dropoffLatitude: mapState.dropoffLocation!.latitude,
                      dropoffLongitude: mapState.dropoffLocation!.longitude,
                      dropoffAddress: mapState.dropoffAddress ?? '',
                      vehicleType: _selectedVehicleType.name,
                    ));
                Navigator.pop(context);
              }
            : null,
        gradientColors: const [MadarTheme.primary, MadarTheme.primaryDark],
      ),
    );
  }
}
