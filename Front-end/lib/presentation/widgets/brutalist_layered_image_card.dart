import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Hitesh Tapaniya Poster Style Lookbook Card:
/// - Tilted Electric Yellow (#FFE600) backing card (-2.5deg, 2.0px Deep Petrol border) behind the photo
/// - Front 4:5 photo container with 2.0px solid Deep Petrol border, 24px radius, and 4px offset shadow
/// - Overlapping tilted white stadium sticker banner ("TOKYO OUTLAW // AW26", 2.0px Petrol border, 4px shadow)
/// - Floating compact Deep Petrol price tag at bottom-right of photo (#0B3B49 box, white text, floating #FFE600 circular + button)
class BrutalistLayeredImageCard extends StatelessWidget {
  final String imageUrl;
  final double height;
  final Widget? topBadge;
  final Widget? bottomTag;
  final String? titleBanner;
  final Widget? overlay;
  final Alignment imageAlignment;
  final String fallbackText;
  final VoidCallback? onTap;

  const BrutalistLayeredImageCard({
    super.key,
    required this.imageUrl,
    this.height = 360,
    this.topBadge,
    this.bottomTag,
    this.titleBanner,
    this.overlay,
    this.imageAlignment = Alignment.topCenter,
    this.fallbackText = 'Street-Zine Lookbook',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Upright Model Photo Container with Soft Dribbble Shadow
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppColors.cardRadius),
                border: Border.all(
                  color: AppColors.hairlineBorder,
                  width: AppColors.cardBorderWidth,
                ),
                boxShadow: AppColors.softDribbbleShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    alignment: imageAlignment,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.iceMintAlabaster,
                      alignment: Alignment.center,
                      child: Text(
                        fallbackText,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          color: AppColors.petrol,
                        ),
                      ),
                    ),
                  ),

                  // Optional overlay (e.g. skeleton painter)
                  ?overlay,

                  // Top badge (e.g. AI Pose Ready / Approved)
                  if (topBadge != null)
                    Positioned(
                      top: 14,
                      left: 14,
                      child: topBadge!,
                    ),

                  // Bottom product tag (Compact Deep Petrol price tag)
                  if (bottomTag != null)
                    Positioned(
                      bottom: 14,
                      right: 14,
                      child: bottomTag!,
                    ),
                ],
              ),
            ),

            // Upright Clean White Stadium Banner at Bottom Edge
            if (titleBanner != null)
              Positioned(
                bottom: -10,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999), // Stadium pill
                    border: Border.all(
                      color: AppColors.hairlineBorder,
                      width: AppColors.cardBorderWidth,
                    ),
                    boxShadow: AppColors.chipShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.coralOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        titleBanner!,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.ink,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
