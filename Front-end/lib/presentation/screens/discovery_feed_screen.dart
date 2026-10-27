import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/spring_interactive_card.dart';
import '../widgets/technical_grid_background.dart';
import 'create_styling_request_screen.dart';
import 'pose_camera_screen.dart';

/// Screen 01: Lookbook Discovery
/// Matches the exact "AI Virtual Try-On Fashion" Dribbble aesthetic:
/// - Top Greeting: "Hey, Alex 👋" + "PoseNova Atelier" with spring-action icons
/// - Hero Sunshine Banner: Dreamy Flamingo-to-Sunset gradient with break-the-box 3D tilted polaroids
/// - Category Pills: Elastic spring feedback with micro-icons and glowing active states
/// - Staggered Lookbook Grid: Cards with ambient colored glow matching outfit hue, frosted stickers, and bouncy touch feedback
class DiscoveryFeedScreen extends StatefulWidget {
  final bool embeddedInShell;
  final ValueChanged<int>? onNavigateToTab;

  const DiscoveryFeedScreen({
    super.key,
    this.embeddedInShell = false,
    this.onNavigateToTab,
  });

  @override
  State<DiscoveryFeedScreen> createState() => _DiscoveryFeedScreenState();
}

class _DiscoveryFeedScreenState extends State<DiscoveryFeedScreen> {
  int _selectedCategoryIndex = 0;
  final Set<int> _likedItems = {0};

  final List<String> _categories = const [
    'All Looks',
    'Streetwear',
    'Editorial',
    'Y2K Pop',
    'Minimal',
  ];

  final List<Map<String, dynamic>> _lookbookItems = [
    {
      'title': 'Tokyo Outlaw • AW26',
      'category': 'Urban Tech Jacket',
      'creatorInfo': 'Maya Trần • 3 Items',
      'stylistAvatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
      'image': 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80',
      'tag': '#StreetTech',
      'sticker': 'STREETWEAR',
      'pose': 'Low Stride Lean',
      'ambientGlow': const Color(0x38F43F5E), // Luminous rose-pink aura
      'matchScore': '98% Match',
      'landmarks': '33 Keypoints',
      'affiliateProducts': [
        {'name': 'Cyber Shield Shell Jacket', 'brand': 'Heliot Emil', 'price': '850.000₫'},
        {'name': 'Tactical Cargo Pants', 'brand': 'Acronym', 'price': '450.000₫'},
        {'name': 'Chunky Lug Sole Boots', 'brand': 'Eytys', 'price': '650.000₫'},
      ],
    },
    {
      'title': 'Minimal Trench • SS26',
      'category': 'Wool Trench Coat',
      'creatorInfo': 'Alex Vũ • 3 Items',
      'stylistAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
      'image': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=80',
      'tag': '#Editorial',
      'sticker': 'CYBER AW26',
      'pose': 'Sleek Standing Stance',
      'ambientGlow': const Color(0x3DFB923C), // Warm sunset peach aura
      'matchScore': '96% Match',
      'landmarks': '33 Keypoints',
      'affiliateProducts': [
        {'name': 'Oversized Wool Trench', 'brand': 'Lemaire', 'price': '1.450.000₫'},
        {'name': 'Minimalist Silk Knit', 'brand': 'Jil Sander', 'price': '520.000₫'},
        {'name': 'Square Toe Leather Mules', 'brand': 'The Row', 'price': '780.000₫'},
      ],
    },
    {
      'title': 'Acid Rave Tech • AW26',
      'category': 'Utility Mesh Vest',
      'creatorInfo': 'Linh Đan • 4 Items',
      'stylistAvatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
      'image': 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?auto=format&fit=crop&w=800&q=80',
      'tag': '#AcidPop',
      'sticker': '30 FPS POSE',
      'pose': 'Dynamic Crouch Pose',
      'ambientGlow': const Color(0x3810B981), // Neo-mint / Emerald glow
      'matchScore': '99% Match',
      'landmarks': '33 Keypoints',
      'affiliateProducts': [
        {'name': 'Acid Pop Mesh Vest', 'brand': 'Diesel', 'price': '620.000₫'},
        {'name': 'Neon Tint Visor', 'brand': 'Oakley', 'price': '280.000₫'},
        {'name': 'Parachute Track Pants', 'brand': 'Balenciaga', 'price': '950.000₫'},
        {'name': 'Rave Chunky Sneakers', 'brand': 'Buffalo', 'price': '650.000₫'},
      ],
    },
    {
      'title': 'Cyber Neo Kimono',
      'category': 'Silk Flare Outer',
      'creatorInfo': 'Kenji Sato • 3 Items',
      'stylistAvatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=80',
      'image': 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=800&q=80',
      'tag': '#NeoKimono',
      'sticker': 'VERIFIED',
      'pose': 'Side Profile Gaze',
      'ambientGlow': const Color(0x38A855F7), // Electric lavender glow
      'matchScore': '95% Match',
      'landmarks': '33 Keypoints',
      'affiliateProducts': [
        {'name': 'Silk Flare Kimono Outer', 'brand': 'Issey Miyake', 'price': '1.200.000₫'},
        {'name': 'Pleated Hakama Trousers', 'brand': 'Yohji Yamamoto', 'price': '950.000₫'},
        {'name': 'Tabi Leather Boots', 'brand': 'Maison Margiela', 'price': '1.100.000₫'},
      ],
    },
  ];

  void _openCamera() {
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab!(1);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PoseCameraScreen()),
      );
    }
  }

  void _openCustomStylingRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateStylingRequestScreen(
          lookbookTitle: 'Personal Custom Styling',
          stylistName: 'Maya Trần',
          budgetVnd: 2500000,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguageController.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: TechnicalGridBackground(
            child: SafeArea(
              top: !widget.embeddedInShell,
              bottom: false,
              child: ListView(
                clipBehavior: Clip.none,
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 140),
                children: [
                  // 1. Top User Greeting Header
                  _buildTopGreetingHeader(),

                  const SizedBox(height: 14),

                  // 2. Wavespace's Highlighted Editorial Typography
                  _buildEditorialHeadline(),

                  const SizedBox(height: 16),

                  // 3. Artistic Tilted Collage Hero Banner
                  _buildHeroCollageBanner(),

                  const SizedBox(height: 16),

                  // 3.5 Dedicated "Gửi Yêu Cầu Phối Đồ" (Custom Styling Brief) Entry Card
                  _buildCustomStylingBriefCard(),

                  const SizedBox(height: 20),

                  // 4. Category Filter Stadium Pills
                  _buildCategoryPills(),

                  // 5. Section Title: "Curated Outfits" (Proper spacing so it never clips)
                  Padding(
                    padding: const EdgeInsets.only(top: 26, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Curated Outfits',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${_lookbookItems.length} Looks Ready',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.roseCoral,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 6. Staggered Editorial Masonry Grid
                  _buildStaggeredMasonryGrid(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 1. Top Header: User greeting + notification & bag icons
  Widget _buildTopGreetingHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hey, Alex',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Virtual Try-On & AI Pose Atelier',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildRoundHeaderButton(Icons.notifications_none),
            const SizedBox(width: 8),
            _buildRoundHeaderButton(Icons.shopping_bag_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildRoundHeaderButton(IconData icon) {
    return SpringInteractiveCard(
      scaleFactor: 0.90,
      onTap: () {},
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
          boxShadow: AppColors.chipShadow,
        ),
        child: Icon(icon, size: 20, color: AppColors.ink),
      ),
    );
  }

  /// 2. Wavespace's Highlighted Editorial Typography
  Widget _buildEditorialHeadline() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Explore & Match Your Next ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF18181B),
              letterSpacing: -0.8,
              height: 1.25,
            ),
          ),
          Transform.rotate(
            angle: -0.035, // ~ -2 degrees
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFBCFE8), // Pastel Flamingo Pink
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1AF43F5E),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                'Iconic',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF18181B),
                  letterSpacing: -0.6,
                ),
              ),
            ),
          ),
          Text(
            ' Pose.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF18181B),
              letterSpacing: -0.8,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Artistic Tilted Collage Hero Banner: Flamingo Pink to Sunset Peach Gradient + Break-the-box 3D Polaroids
  Widget _buildHeroCollageBanner() {
    return Container(
      height: 195,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.bannerGradient, // #F472B6 -> #FB923C -> #FBBF24
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33F43F5E),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.none,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background soft radial aura light
          Positioned(
            right: 20,
            bottom: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
          ),

          // Left Headline & CTA Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 165, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 1.0),
                        boxShadow: AppColors.chipShadow,
                      ),
                      child: Text(
                        '50% FASTER FIT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepRoseText,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Elevate Your\nEveryday Style.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ],
                ),
                SpringInteractiveCard(
                  scaleFactor: 0.94,
                  onTap: _openCamera,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Try AI Camera →',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF18181B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right Side: Wavespace Tilted Polaroid Collage (2 Overlapping Photos breaking out of the box)
          Positioned(
            right: 2,
            top: -8,
            bottom: -8,
            width: 165,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerRight,
              children: [
                // Polaroid 1 (Back / Upper): -5.2deg rotation
                Positioned(
                  right: 48,
                  top: 2,
                  child: Transform.rotate(
                    angle: -0.09, // ~ -5.2 degrees
                    child: Container(
                      width: 94,
                      height: 138,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white, width: 3.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x38000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=300&q=80',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Container(
                            height: 18,
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: Text(
                              'AW26 // EDITORIAL',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 7,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Polaroid 2 (Front / Lower): +3.5deg rotation overlapping Polaroid 1
                Positioned(
                  right: 6,
                  top: 24,
                  child: Transform.rotate(
                    angle: 0.06, // ~ +3.5 degrees
                    child: Container(
                      width: 104,
                      height: 148,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white, width: 4.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Color(0x33F43F5E),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=300&q=80',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                                // Pure Text LIVE indicator pill on front photo
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.white24, width: 0.6),
                                    ),
                                    child: Text(
                                      'LIVE FIT',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 7,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 20,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            alignment: Alignment.center,
                            child: Text(
                              '98% AI MATCH',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: AppColors.roseCoral,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dedicated "Gửi Yêu Cầu Phối Đồ" (Custom Styling Brief) Entry Card
  Widget _buildCustomStylingBriefCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14F43F5E),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.rosePinkSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '1-ON-1 PERSONAL STYLING',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coralOrange,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                'ESCROW PROTECTED',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10B981),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Cần Phối Đồ Riêng Theo Vóc Dáng?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gửi yêu cầu cho Stylist • Bảo vệ 100% qua Ký quỹ Escrow',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          SpringInteractiveCard(
            scaleFactor: 0.96,
            onTap: _openCustomStylingRequest,
            child: Container(
              width: double.infinity,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.buttonShadow,
              ),
              alignment: Alignment.center,
              child: Text(
                'Gửi Yêu Cầu Phối Đồ →',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Category Pills Row: Pure Editorial Typography (Zero AI Icons)
  Widget _buildCategoryPills() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final label = _categories[index];

          return SpringInteractiveCard(
            scaleFactor: 0.94,
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.hairlineBorder,
                  width: 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.roseCoral.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : AppColors.chipShadow,
              ),
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.ink,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 5. Staggered Editorial Masonry Lookbook Grid (Wavespace Style)
  Widget _buildStaggeredMasonryGrid() {
    // 2-column masonry layout:
    // Left column: items [0], [2] (starts at top 0px)
    // Right column: items [1], [3] (offset 24px lower with layout-safe SizedBox instead of Transform.translate)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          child: Column(
            children: [
              _buildMasonryCardItem(_lookbookItems[0], 0),
              const SizedBox(height: 18),
              if (_lookbookItems.length > 2)
                _buildMasonryCardItem(_lookbookItems[2], 2),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // Right Column (Offset 24px lower with real SizedBox)
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 24),
              if (_lookbookItems.length > 1)
                // Featured card has a subtle -1.2deg artistic tilt
                Transform.rotate(
                  angle: -0.021, // -1.2 degrees
                  child: _buildMasonryCardItem(_lookbookItems[1], 1, isFeatured: true),
                ),
              const SizedBox(height: 18),
              if (_lookbookItems.length > 3)
                _buildMasonryCardItem(_lookbookItems[3], 3),
            ],
          ),
        ),
      ],
    );
  }

  /// Single Masonry Lookbook Card Item with Ambient Colored Glow & Frosted Stickers
  Widget _buildMasonryCardItem(Map<String, dynamic> item, int index, {bool isFeatured = false}) {
    final isLiked = _likedItems.contains(index);

    return SpringInteractiveCard(
      scaleFactor: 0.97,
      onTap: _openCamera,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isFeatured ? AppColors.pastelFlamingo : AppColors.hairlineBorder,
            width: 1.0,
          ),
          boxShadow: [
            // 1. Ambient colored aura matching the outfit's signature hue
            BoxShadow(
              color: (item['ambientGlow'] as Color? ?? AppColors.roseCoral.withValues(alpha: 0.22)),
              blurRadius: isFeatured ? 28 : 22,
              spreadRadius: -2,
              offset: const Offset(0, 10),
            ),
            // 2. Soft base grounding shadow
            const BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container with Floating Overlays (Clean Model Photo)
            SizedBox(
              height: isFeatured ? 205 : 190,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item['image'] as String,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.pastelFlamingo,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white54),
                      ),
                    ),
                  ),

                  // Frosted Glassmorphism Sticker Overlapping Photo Top-Left (Pure Editorial Typography)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.92),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            item['sticker'] as String? ?? 'TRENDING',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.deepRoseText,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Top-Right Circular Heart Badge with Spring Tap
                  Positioned(
                    top: 10,
                    right: 10,
                    child: SpringInteractiveCard(
                      scaleFactor: 0.82,
                      onTap: () {
                        setState(() {
                          if (isLiked) {
                            _likedItems.remove(index);
                          } else {
                            _likedItems.add(index);
                          }
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: AppColors.chipShadow,
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isLiked ? AppColors.roseCoral : AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Info Card Section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Creator & Affiliate Items row: Avatar + "Maya Trần • 3 Items" (12px muted grey)
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Image.network(
                          item['stylistAvatar'] as String,
                          width: 16,
                          height: 16,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 16,
                            height: 16,
                            color: AppColors.pastelFlamingo,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item['creatorInfo'] as String? ?? 'Maya Trần • 3 Items',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ONE FULL-WIDTH CAMERA BUTTON AT THE BOTTOM OF THE CARD
                  SpringInteractiveCard(
                    scaleFactor: 0.95,
                    onTap: _openCamera,
                    child: Container(
                      width: double.infinity,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppColors.buttonShadow,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Chụp Dáng AI →',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
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
}
