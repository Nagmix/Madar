import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippo_shared/trippo_shared.dart';
import '../../../map/presentation/notifiers/map_notifier.dart';

/// شاشة اختيار الموقع - مدار
/// شاشة منفصلة لاختيار نقطة الانطلاق أو الوجهة
/// تحتوي على: شريط بحث + زر الموقع الحالي + خريطة واضحة + زر تأكيد

enum LocationPickerMode {
  pickup,   // اختيار نقطة الانطلاق
  dropoff,  // اختيار الوجهة
}

class LocationPickerScreen extends ConsumerStatefulWidget {
  final LocationPickerMode mode;
  final LatLng? initialPosition;

  const LocationPickerScreen({
    super.key,
    required this.mode,
    this.initialPosition,
  });

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _searchController = TextEditingController();
  final MapController _mapController = MapController();
  Timer? _debounceTimer;
  bool _isSearching = false;
  List<PlaceResult> _searchResults = [];
  LatLng? _selectedPosition;
  String _selectedAddress = '';
  bool _isMapReady = false;
  bool _isConfirming = false;

  static const LatLng _defaultLocation = LatLng(15.3694, 44.1910);

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition ?? _defaultLocation;
    _initLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      if (widget.initialPosition != null) {
        _selectedPosition = widget.initialPosition;
        _reverseGeocode(_selectedPosition!);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _selectedPosition = _defaultLocation);
        _reverseGeocode(_selectedPosition!);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final loc = LatLng(position.latitude, position.longitude);
      setState(() => _selectedPosition = loc);
      if (_isMapReady) {
        _mapController.move(loc, 16.0);
      }
      _reverseGeocode(loc);
    } catch (e) {
      setState(() => _selectedPosition = _defaultLocation);
      _reverseGeocode(_selectedPosition!);
    }
  }

  Future<void> _goToMyLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يرجى السماح بالوصول إلى الموقع')),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final loc = LatLng(position.latitude, position.longitude);
      setState(() => _selectedPosition = loc);
      if (_isMapReady) {
        _mapController.move(loc, 16.0);
      }
      _reverseGeocode(loc);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم العثور على الموقع: $e')),
        );
      }
    }
  }

  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final mapService = MapService();
      final result = await mapService.reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (mounted) {
        setState(() {
          _selectedAddress = result.shortAddress.isNotEmpty
              ? result.shortAddress
              : result.fullAddress;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _selectedAddress = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  void _searchPlaces(String query) {
    _debounceTimer?.cancel();
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
          setState(() { _isSearching = false; _searchResults = []; });
        }
      }
    });
  }

  void _selectSearchResult(PlaceResult place) {
    final loc = LatLng(place.location.latitude, place.location.longitude);
    setState(() {
      _selectedPosition = loc;
      _selectedAddress = place.shortAddress;
      _searchResults = [];
      _searchController.clear();
    });
    if (_isMapReady) {
      _mapController.move(loc, 16.0);
    }
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _selectedPosition = point;
    });
    _reverseGeocode(point);
  }

  void _onMapPositionChanged(MapPosition position, bool hasGesture) {
    if (hasGesture && position.center != null) {
      setState(() {
        _selectedPosition = position.center!;
      });
      _reverseGeocode(position.center!);
    }
  }

  Future<void> _confirmLocation() async {
    if (_selectedPosition == null) return;
    setState(() => _isConfirming = true);

    try {
      final mapNotifier = ref.read(mapLocationProvider.notifier);

      if (widget.mode == LocationPickerMode.pickup) {
        await mapNotifier.setPickupLocation(_selectedPosition!, _selectedAddress);
      } else {
        await mapNotifier.setDropoffLocation(_selectedPosition!, _selectedAddress);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPickup = widget.mode == LocationPickerMode.pickup;
    final title = isPickup ? 'تحديد نقطة الانطلاق' : 'تحديد الوجهة';
    final pinColor = isPickup ? MadarTheme.mapPickup : MadarTheme.mapDropoff;
    final confirmText = isPickup ? 'تأكيد نقطة الانطلاق' : 'تأكيد الوجهة';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedPosition ?? _defaultLocation,
                initialZoom: 16.0,
                onTap: (tapPosition, point) => _onMapTap(point),
                onMapReady: () {
                  _isMapReady = true;
                  if (_selectedPosition != null) {
                    _mapController.move(_selectedPosition!, 16.0);
                  }
                },
                onPositionChanged: _onMapPositionChanged,
                minZoom: 10.0,
                maxZoom: 19.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: TileProviderLayer.lightThemeTileUrl,
                  userAgentPackageName: 'com.madar.rider',
                  retinaMode: TileProviderLayer.lightThemeSupportsRetina,
                  maxZoom: 19,
                  maxNativeZoom: 18,
                ),
                // Center pin marker
                if (_selectedPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPosition!,
                        width: 50,
                        height: 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: pinColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(color: pinColor.withOpacity(0.4), blurRadius: 8),
                                ],
                              ),
                              child: Text(
                                _selectedAddress.isNotEmpty ? _truncateAddress(_selectedAddress) : '...',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              isPickup ? Icons.trip_origin : Icons.location_on,
                              color: pinColor,
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),

          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _buildSearchBar(title),
          ),

          // Search results
          if (_searchResults.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 65,
              left: 16,
              right: 16,
              child: _buildSearchResults(),
            ),

          // My location button
          Positioned(
            right: 16,
            bottom: 120,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [MadarTheme.shadow(blur: 10)],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _goToMyLocation,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.my_location, color: MadarTheme.primary, size: 24),
                  ),
                ),
              ),
            ),
          ),

          // Bottom confirm section
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildConfirmSection(confirmText, pinColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [MadarTheme.shadow(blur: 15)],
      ),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).pop(false),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Icon(Icons.arrow_back, color: MadarTheme.primary),
              ),
            ),
          ),
          // Search field
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _searchPlaces,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'ابحث عن موقع...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          // Search indicator
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: MadarTheme.primary),
              onPressed: () => _searchPlaces(_searchController.text),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [MadarTheme.shadow(blur: 10)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchResults.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final place = _searchResults[index];
          return ListTile(
            leading: const Icon(Icons.place, color: MadarTheme.primary),
            title: Text(
              place.shortAddress,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              place.fullAddress,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _selectSearchResult(place),
          );
        },
      ),
    );
  }

  Widget _buildConfirmSection(String confirmText, Color pinColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected address display
            Row(
              children: [
                Icon(
                  widget.mode == LocationPickerMode.pickup
                      ? Icons.trip_origin
                      : Icons.location_on,
                  color: pinColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedAddress.isNotEmpty ? _selectedAddress : 'جارٍ تحديد الموقع...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedAddress.isNotEmpty ? Colors.black87 : Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isConfirming ? null : _confirmLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pinColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MadarTheme.radiusLg),
                  ),
                  elevation: 3,
                ),
                child: _isConfirming
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateAddress(String address) {
    if (address.length > 25) return '${address.substring(0, 22)}...';
    return address;
  }
}
