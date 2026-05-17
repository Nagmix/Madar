import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../map/presentation/notifiers/map_notifier.dart';
import '../../../trip/presentation/notifiers/trip_notifier.dart';
import '../../../../core/constants/app_theme.dart';

/// ورقة اختيار الوجهة - مدار
class WhereToSheet extends ConsumerStatefulWidget {
  const WhereToSheet({super.key});

  @override
  ConsumerState<WhereToSheet> createState() => _WhereToSheetState();
}

class _WhereToSheetState extends ConsumerState<WhereToSheet> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<PlaceResult> _searchResults = [];
  VehicleType _selectedVehicleType = VehicleType.sedan;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 2) {
      setState(() { _searchResults = []; _isSearching = false; });
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await ref.read(mapLocationProvider.notifier).searchPlaces(query);
      setState(() { _searchResults = results; _isSearching = false; });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _selectDestination(PlaceResult place) {
    ref.read(mapLocationProvider.notifier).setDropoffLocation(place.location, place.shortAddress);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapLocationProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -4))]),
      child: Column(children: [
        Center(child: Container(margin: const EdgeInsets.only(top: 8), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'ابحث عن وجهتك...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _searchResults = []); }) : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true, fillColor: Colors.grey[100],
            ),
            onChanged: _searchPlaces,
          ),
        ),
        if (mapState.pickupAddress != null)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildLocationPoints(mapState)),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isNotEmpty
                  ? ListView.builder(itemCount: _searchResults.length, itemBuilder: (context, index) => _buildSearchResultItem(_searchResults[index]))
                  : _buildSavedPlaces(),
        ),
        if (mapState.dropoffLocation != null) ...[
          _buildVehicleSelection(),
          _buildRequestButton(mapState),
        ],
      ]),
    );
  }

  Widget _buildLocationPoints(MapLocationState mapState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.radio_button_checked, color: Color(0xFF00C853), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(mapState.pickupAddress ?? 'موقعك الحالي', style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        if (mapState.dropoffAddress != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.location_on, color: Color(0xFFFF1744), size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(mapState.dropoffAddress!, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
            GestureDetector(onTap: () => ref.read(mapLocationProvider.notifier).clearDropoff(), child: const Icon(Icons.close, size: 18)),
          ]),
        ],
      ]),
    );
  }

  Widget _buildSearchResultItem(PlaceResult place) {
    return ListTile(
      leading: const Icon(Icons.location_on, color: Color(0xFFFF1744)),
      title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(place.fullAddress, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      onTap: () => _selectDestination(place),
    );
  }

  Widget _buildSavedPlaces() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search, size: 48, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('ابحث عن وجهتك', style: TextStyle(color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildVehicleSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('اختر نوع المركبة', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),
        Row(children: [
          _vehicleOption(Icons.directions_car, 'سيدان', VehicleType.sedan),
          const SizedBox(width: 8),
          _vehicleOption(Icons.local_taxi, 'مريح', VehicleType.suv),
          const SizedBox(width: 8),
          _vehicleOption(Icons.airport_shuttle, 'فان', VehicleType.van),
        ]),
      ]),
    );
  }

  Widget _vehicleOption(IconData icon, String name, VehicleType type) {
    final selected = _selectedVehicleType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedVehicleType = type),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF00C853).withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? const Color(0xFF00C853) : Colors.grey[200]!),
          ),
          child: Column(children: [
            Icon(icon, color: selected ? const Color(0xFF00C853) : Colors.grey[600], size: 24),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
          ]),
        ),
      ),
    );
  }

  Widget _buildRequestButton(MapLocationState mapState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: mapState.dropoffLocation != null ? () {
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
          } : null,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('طلب رحلة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
