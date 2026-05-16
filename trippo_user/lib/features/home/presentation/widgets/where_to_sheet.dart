import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trippo_shared/trippo_shared.dart';
import 'package:trippo_user/Model/predicted_places.dart';
import '../../../map/presentation/notifiers/map_notifier.dart';
import '../../../trip/presentation/notifiers/trip_notifier.dart';
import '../notifiers/promo_notifier.dart';
import '../../../../core/constants/app_theme.dart';

/// Where To Sheet - Bottom sheet for destination search and vehicle selection
class WhereToSheet extends ConsumerStatefulWidget {
  const WhereToSheet({super.key});

  @override
  ConsumerState<WhereToSheet> createState() => _WhereToSheetState();
}

class _WhereToSheetState extends ConsumerState<WhereToSheet> {
  final _searchController = TextEditingController();
  final _promoController = TextEditingController();
  bool _isSearching = false;
  VehicleType _selectedVehicleType = VehicleType.sedan;

  @override
  void dispose() {
    _searchController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapLocationProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Where to? search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: GestureDetector(
              onTap: () => _openSearchScreen(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[500]),
                    const SizedBox(width: 12),
                    Text(
                      'Where to?',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (mapState.dropoffAddress != null)
                      GestureDetector(
                        onTap: () {
                          ref.read(mapLocationProvider.notifier).clearDropoff();
                          // Also clear promo when destination is cleared
                          ref.read(promoProvider.notifier).removePromo();
                          _promoController.clear();
                        },
                        child: const Icon(Icons.close, size: 18),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Pickup/Dropoff points if destination set
          if (mapState.pickupAddress != null || mapState.dropoffAddress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLocationPoints(mapState),
            ),

          // Vehicle type selection if destination set
          if (mapState.dropoffLocation != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildVehicleSelection(),
            ),

          // Promo code section if destination set
          if (mapState.dropoffLocation != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildPromoSection(),
            ),

          // Request Ride button if destination set
          if (mapState.dropoffLocation != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildFareSummaryAndRequestButton(),
            ),

          // Recent places
          if (mapState.dropoffLocation == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildRecentPlaces(),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLocationPoints(MapLocationState mapState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (mapState.pickupAddress != null)
            _buildLocationRow(
              icon: Icons.radio_button_checked,
              iconColor: AppTheme.primary,
              title: 'Pickup',
              subtitle: mapState.pickupAddress!,
            ),
          if (mapState.pickupAddress != null && mapState.dropoffAddress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildDottedLine(),
            ),
          if (mapState.dropoffAddress != null)
            _buildLocationRow(
              icon: Icons.location_on,
              iconColor: AppTheme.error,
              title: 'Destination',
              subtitle: mapState.dropoffAddress!,
            ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDottedLine() {
    return SizedBox(
      height: 20,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: List.generate(
              (constraints.maxHeight / 4).floor(),
              (_) => Expanded(
                child: Container(
                  height: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleSelection() {
    final vehicleTypes = [
      (VehicleType.motorcycle, '1-2 min', '\$5-8'),
      (VehicleType.sedan, '2-4 min', '\$8-15'),
      (VehicleType.suv, '3-5 min', '\$12-22'),
      (VehicleType.luxury, '5-8 min', '\$20-35'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose a ride',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...vehicleTypes.map((v) => _buildVehicleOption(
          type: v.$1,
          eta: v.$2,
          priceRange: v.$3,
        )),
      ],
    );
  }

  Widget _buildVehicleOption({
    required VehicleType type,
    required String eta,
    required String priceRange,
  }) {
    final isSelected = _selectedVehicleType == type;
    final promoState = ref.watch(promoProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() => _selectedVehicleType = type);
          // If a promo is applied, re-validate it for the new vehicle type
          if (promoState.hasPromo) {
            final fareAmount = _getEstimatedFare(type);
            ref.read(promoProvider.notifier).validatePromo(
              promoState.appliedPromo!.code,
              fareAmount,
              type.name,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppTheme.primary.withOpacity(0.05) : null,
          ),
          child: Row(
            children: [
              Text(type.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppTheme.primary : null,
                      ),
                    ),
                    Text(eta, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              // Fare display - show strikethrough + discounted if promo applied
              _buildFareDisplay(priceRange, promoState, type),
            ],
          ),
        ),
      ),
    );
  }

  /// Build fare display for a vehicle option, accounting for promo discounts
  Widget _buildFareDisplay(String priceRange, PromoState promoState, VehicleType type) {
    if (!promoState.hasPromo || _selectedVehicleType != type) {
      return Text(
        priceRange,
        style: const TextStyle(fontWeight: FontWeight.w600),
      );
    }

    // When promo is applied for the selected vehicle type
    final estimatedFare = _getEstimatedFare(type);
    final discountedFare = promoState.discountedFare(estimatedFare);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${estimatedFare.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            color: Colors.grey[500],
            decoration: TextDecoration.lineThrough,
          ),
        ),
        Text(
          '\$${discountedFare.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  // ==================== Promo Code Section ====================

  Widget _buildPromoSection() {
    final promoState = ref.watch(promoProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        const Divider(height: 24, thickness: 1),

        // Section header
        Row(
          children: [
            Icon(Icons.local_offer_outlined, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            const Text(
              'Promo Code',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Show applied promo or input field
        if (promoState.hasPromo)
          _buildAppliedPromoCard(promoState)
        else
          _buildPromoInputField(promoState),
      ],
    );
  }

  /// Build the promo code input field with Apply button
  Widget _buildPromoInputField(PromoState promoState) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                enabled: !promoState.isValidating,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Enter promo code',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.confirmation_number_outlined, size: 20, color: Colors.grey[400]),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  isDense: true,
                ),
                onChanged: (_) {
                  // Clear error when user starts typing
                  if (promoState.validationError != null) {
                    ref.read(promoProvider.notifier).clearError();
                  }
                },
                onSubmitted: (_) => _applyPromo(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: promoState.isValidating ? null : _applyPromo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: promoState.isValidating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Apply',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
              ),
            ),
          ],
        ),

        // Validation feedback
        if (promoState.isValidating)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Validating promo code...',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),

        if (promoState.validationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 14, color: AppTheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    promoState.validationError!,
                    style: const TextStyle(fontSize: 12, color: AppTheme.error),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Build the applied promo card showing code, discount, and remove button
  Widget _buildAppliedPromoCard(PromoState promoState) {
    final promo = promoState.appliedPromo!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Success icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),

              // Promo code name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.primary,
                      ),
                    ),
                    if (promo.description.isNotEmpty)
                      Text(
                        promo.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Discount amount in green
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatDiscount(promo, promoState.discountAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Savings info and Remove button row
          Row(
            children: [
              // Savings amount
              Expanded(
                child: Text(
                  'You save \$${promoState.discountAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),

              // Remove button
              GestureDetector(
                onTap: () {
                  ref.read(promoProvider.notifier).removePromo();
                  _promoController.clear();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.error.withOpacity(0.05),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, size: 14, color: AppTheme.error),
                      SizedBox(width: 4),
                      Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== Fare Summary & Request Button ====================

  Widget _buildFareSummaryAndRequestButton() {
    final promoState = ref.watch(promoProvider);
    final estimatedFare = _getEstimatedFare(_selectedVehicleType);

    return Column(
      children: [
        // Fare breakdown when promo is applied
        if (promoState.hasPromo) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated fare',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Text(
                  '\$${estimatedFare.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Promo discount',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Text(
                  '-\$${promoState.discountAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discounted fare',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${promoState.discountedFare(estimatedFare).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Simple fare display when no promo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated fare',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Text(
                  '\$${estimatedFare.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _requestRide,
            child: const Text('Request Ride'),
          ),
        ),
      ],
    );
  }

  // ==================== Recent Places ====================

  Widget _buildRecentPlaces() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _buildRecentPlaceItem(Icons.work, 'Office', 'Downtown Business District'),
        _buildRecentPlaceItem(Icons.home, 'Home', 'Al Olaya District'),
        _buildRecentPlaceItem(Icons.local_mall, 'Mall', 'Kingdom Centre'),
      ],
    );
  }

  Widget _buildRecentPlaceItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      onTap: () {},
    );
  }

  // ==================== Helpers ====================

  /// Get estimated fare for a vehicle type (using mid-range of price estimates)
  double _getEstimatedFare(VehicleType type) {
    switch (type) {
      case VehicleType.motorcycle:
        return 6.50;
      case VehicleType.sedan:
        return 11.50;
      case VehicleType.suv:
        return 17.00;
      case VehicleType.van:
        return 20.00;
      case VehicleType.luxury:
        return 27.50;
    }
  }

  /// Format the discount display for a promo badge
  String _formatDiscount(PromoCode promo, double discountAmount) {
    if (promo.type == PromoDiscountType.percentage) {
      return '-${promo.value.toStringAsFixed(0)}%';
    } else {
      return '-\$${discountAmount.toStringAsFixed(2)}';
    }
  }

  /// Apply the promo code entered in the text field
  void _applyPromo() {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    final fareAmount = _getEstimatedFare(_selectedVehicleType);
    ref.read(promoProvider.notifier).validatePromo(
      code,
      fareAmount,
      _selectedVehicleType.name,
    );
  }

  void _openSearchScreen(BuildContext context) {
    // Navigate to search screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _SearchScreen(),
    );
  }

  void _requestRide() {
    // Create trip via trip notifier
    final mapState = ref.read(mapLocationProvider);
    if (mapState.pickupLocation == null || mapState.dropoffLocation == null) return;

    ref.read(tripProvider.notifier).createTrip(
      CreateTripRequest(
        pickupLatitude: mapState.pickupLocation!.latitude,
        pickupLongitude: mapState.pickupLocation!.longitude,
        pickupAddress: mapState.pickupAddress ?? '',
        dropoffLatitude: mapState.dropoffLocation!.latitude,
        dropoffLongitude: mapState.dropoffLocation!.longitude,
        dropoffAddress: mapState.dropoffAddress ?? '',
        vehicleType: _selectedVehicleType.name,
        promoCode: ref.read(promoProvider).appliedPromo?.code,
      ),
    );
  }
}

/// Search Screen for destination
class _SearchScreen extends ConsumerStatefulWidget {
  const _SearchScreen();

  @override
  ConsumerState<_SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<_SearchScreen> {
  final _searchController = TextEditingController();
  List<PredictedPlaces> _results = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search destination...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? _buildEmptyState()
                    : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Search for a destination',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final place = _results[index];
        return ListTile(
          leading: const Icon(Icons.location_on_outlined),
          title: Text(place.mainText ?? ''),
          subtitle: Text(place.secText ?? ''),
          onTap: () => _selectPlace(place),
        );
      },
    );
  }

  void _onSearchChanged(String value) {
    // Debounce and search places
  }

  void _selectPlace(PredictedPlaces place) {
    // Set dropoff location and pop
    Navigator.pop(context);
  }
}
