import 'package:flutter/material.dart';
import 'package:trippo_shared/trippo_shared.dart';

/// شاشة التقييم - مدار
class RatingScreen extends StatefulWidget {
  final TripModel trip;

  const RatingScreen({super.key, required this.trip});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen>
    with TickerProviderStateMixin {
  double _rating = 0;
  final Set<String> _selectedTags = {};
  final _reviewController = TextEditingController();
  late AnimationController _starController;
  late List<Animation<double>> _starAnimations;

  final _ratingTags = [
    ('سائق ودود', Icons.emoji_emotions),
    ('سيارة نظيفة', Icons.directions_car),
    ('قيادة آمنة', Icons.shield),
    ('طريق جيد', Icons.route),
    ('في الموعد', Icons.schedule),
    ('محادثة لطيفة', Icons.chat),
  ];

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _starAnimations = List.generate(
      5,
      (index) => Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _starController,
          curve: Interval(index * 0.1, 1.0, curve: Curves.elasticOut),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _starController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _onStarTap(int index) {
    setState(() => _rating = (index + 1).toDouble());
    _starController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MadarAppBar(
        title: 'تقييم الرحلة',
        showBack: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(MadarTheme.space24),
        child: Column(
          children: [
            // بطاقة ملخص الرحلة
            _buildTripSummaryCard(),

            const SizedBox(height: MadarTheme.space32),

            // معلومات السائق
            if (widget.trip.driver != null) ...[
              _buildDriverInfo(),
              const SizedBox(height: MadarTheme.space32),
            ],

            // التقييم بالنجوم
            Text(
              'قيّم رحلتك',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: MadarTheme.fontFamily,
                color: MadarTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اختر التقييم',
              style: TextStyle(
                fontSize: 14,
                color: MadarTheme.textSecondary,
                fontFamily: MadarTheme.fontFamily,
              ),
            ),
            const SizedBox(height: MadarTheme.space20),
            _buildStarRating(),

            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Text(
                _getRatingLabel(_rating),
                style: TextStyle(
                  color: MadarTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: MadarTheme.fontFamily,
                ),
              ),
            ],

            const SizedBox(height: MadarTheme.space24),

            // علامات التقييم
            if (_rating > 0) ...[
              Text(
                'ما الذي أعجبك؟',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  fontFamily: MadarTheme.fontFamily,
                  color: MadarTheme.textPrimary,
                ),
              ),
              const SizedBox(height: MadarTheme.space12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ratingTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag.$1);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tag.$2, size: 14,
                              color: isSelected
                                  ? MadarTheme.primary
                                  : MadarTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(tag.$1),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: MadarTheme.primaryLight,
                      checkmarkColor: MadarTheme.primary,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag.$1);
                          } else {
                            _selectedTags.remove(tag.$1);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: MadarTheme.space20),
            ],

            // حقل الملاحظات
            Text(
              'ملاحظات إضافية',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                fontFamily: MadarTheme.fontFamily,
                color: MadarTheme.textPrimary,
              ),
            ),
            const SizedBox(height: MadarTheme.space8),
            MadarTextField(
              controller: _reviewController,
              hint: 'أضف تعليقاً (اختياري)',
              maxLines: 3,
            ),

            const SizedBox(height: MadarTheme.space32),

            // زر الإرسال
            MadarGradientButton(
              label: 'إرسال التقييم',
              onPressed: _rating > 0 ? _submitRating : null,
              gradientColors: const [MadarTheme.primary, MadarTheme.primaryDark],
            ),

            const SizedBox(height: 8),

            // تخطي
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'تخطي',
                style: TextStyle(
                  color: MadarTheme.textSecondary,
                  fontFamily: MadarTheme.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── بطاقة ملخص الرحلة ──
  Widget _buildTripSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(MadarTheme.space16),
      decoration: MadarTheme.cardDecoration(),
      child: Column(
        children: [
          MadarLocationPoint(
            isPickup: true,
            address: widget.trip.pickupLocation.address ?? 'نقطة الانطلاق',
          ),
          const SizedBox(height: MadarTheme.space8),
          MadarLocationPoint(
            isPickup: false,
            address: widget.trip.dropoffLocation.address ?? 'نقطة الوصول',
          ),
          const Divider(height: MadarTheme.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي الأجرة',
                style: TextStyle(
                  color: MadarTheme.textSecondary,
                  fontFamily: MadarTheme.fontFamily,
                ),
              ),
              MadarPriceTag(
                amount: widget.trip.fareBreakdown?.totalFare ?? 0,
                fontSize: 20,
                color: MadarTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── معلومات السائق ──
  Widget _buildDriverInfo() {
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: MadarTheme.primary.withOpacity(0.1),
          child: Text(
            widget.trip.driver!.name.isNotEmpty
                ? widget.trip.driver!.name[0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: MadarTheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.trip.driver!.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: MadarTheme.fontFamily,
          ),
        ),
        Text(
          '${widget.trip.driver!.vehicle.name} • ${widget.trip.driver!.vehicle.plateNumber}',
          style: TextStyle(
            color: MadarTheme.textSecondary,
            fontSize: 13,
            fontFamily: MadarTheme.fontFamily,
          ),
        ),
      ],
    );
  }

  // ── التقييم بالنجوم ──
  Widget _buildStarRating() {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = (index + 1).toDouble();
            final isFilled = starValue <= _rating;
            final scale =
                isFilled && _starController.isAnimating
                    ? _starAnimations[index].value
                    : 1.0;
            return GestureDetector(
              onTap: () => _onStarTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Transform.scale(
                  scale: scale,
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    color: isFilled
                        ? MadarTheme.accent
                        : MadarTheme.textHint.withOpacity(0.4),
                    size: 44,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  String _getRatingLabel(double rating) => switch (rating) {
        1 => 'سيء جداً',
        2 => 'سيء',
        3 => 'مقبول',
        4 => 'جيد',
        5 => 'ممتاز',
        _ => '',
      };

  void _submitRating() {
    Navigator.pop(context, {
      'rating': _rating,
      'review': _reviewController.text,
      'tags': _selectedTags.toList(),
    });
  }
}

