import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Signature Component 1: Sticker Tag Đính Áo (PRODUCT_TAG)
/// White pill with hairline border, soft shadow, Coral-Orange LED dot, and Plus Jakarta Sans text.
class StickerProductTag extends StatelessWidget {
  final String productName;
  final String priceText;
  final Color dotColor;
  final VoidCallback? onTap;
  final double rotateAngle;

  const StickerProductTag({
    super.key,
    required this.productName,
    required this.priceText,
    this.dotColor = AppColors.coralOrange,
    this.onTap,
    this.rotateAngle = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.ink,
                content: Row(
                  children: [
                    const Icon(Icons.shopping_bag, color: AppColors.coralOrange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Affiliate Link: $productName ($priceText)',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999), // Pill shape
          border: Border.all(
            color: AppColors.hairlineBorder,
            width: 1.0,
          ),
          boxShadow: AppColors.chipShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chấm tròn LED định vị (Coral Orange)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            // Thông số Plus Jakarta Sans
            Text(
              '$productName · $priceText',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
