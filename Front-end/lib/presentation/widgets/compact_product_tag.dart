import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Compact Fashion Product Tag
/// Frosted white price capsule with dark espresso price and Coral-Orange '+' button.
class CompactProductTag extends StatelessWidget {
  final String category;
  final String priceText;
  final VoidCallback? onTap;

  const CompactProductTag({
    super.key,
    String? category,
    String? productName,
    required this.priceText,
    this.onTap,
  }) : category = category ?? productName ?? 'Utility Jacket';

  @override
  Widget build(BuildContext context) {
    String displayPrice = priceText;
    if (priceText.contains('1.250.000')) {
      displayPrice = '1.250K';
    } else if (priceText.contains('2.500.000')) {
      displayPrice = '2.500K';
    }

    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.ink,
                content: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: AppColors.coralOrange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Affiliate Link: $category ($priceText)',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.hairlineBorder,
            width: 1.0,
          ),
          boxShadow: AppColors.chipShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayPrice,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.ink,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            // Floating Coral-Orange Circular + Button
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppColors.buttonShadow,
              ),
              child: const Icon(
                Icons.add,
                size: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
