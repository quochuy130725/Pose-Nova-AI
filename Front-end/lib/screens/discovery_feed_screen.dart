import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/localization/app_language.dart';
import '../core/theme/app_colors.dart';
import '../providers/lookbook_provider.dart';
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
  final Set<String> _likedItemKeys = {'0'};

  @override
  void initState() {
    super.initState();
    _syncLiveLookbooks();
  }

  Future<void> _syncLiveLookbooks() async {
    final liveItems = await LookbookProvider.instance.fetchLookbooks();
    if (!mounted || liveItems.isEmpty) return;
    setState(() {
      final ambientColors = [
        const Color(0x38F43F5E), // Luminous rose-pink aura
        const Color(0x3DFB923C), // Warm sunset peach aura
        const Color(0x3810B981), // Neo-mint / Emerald glow
        const Color(0x38A855F7), // Electric lavender glow
        const Color(0x383B82F6), // Cyber sky blue
      ];
      final newItems = <Map<String, dynamic>>[];
      for (int i = 0; i < liveItems.length; i++) {
        final item = liveItems[i];
        final title = item['title']?.toString() ?? 'Lookbook';
        final category = item['styleCategory']?.toString() ?? item['category']?.toString() ?? 'Streetwear';
        final imageUrl = item['imageUrl']?.toString() ?? item['image']?.toString() ?? '';
        final creator = item['stylist']?['fullName'] ?? item['creatorInfo'] ?? 'Maya Trần • 3 Items';
        newItems.add({
          'id': item['id'],
          'title': title,
          'category': category,
          'styleCategory': category,
          'creatorInfo': creator,
          'stylistAvatar': item['stylist']?['avatarUrl'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
          'image': imageUrl,
          'imageUrl': imageUrl,
          'tag': '#${category.replaceAll(' ', '')}',
          'sticker': category.toUpperCase(),
          'pose': item['description'] ?? 'Editorial Pose',
          'ambientGlow': ambientColors[i % ambientColors.length],
          'matchScore': '98% Match',
          'landmarks': '33 Keypoints',
          'poseLandmarksJson': item['poseLandmarksJson'],
          'affiliateProducts': item['productTags'] ?? [],
        });
      }
      if (newItems.isNotEmpty) {
        _lookbookItems = newItems;
      }
    });
  }

  final List<String> _categories = const [
    'All Looks',
    'Streetwear',
    'Editorial',
    'Y2K Pop',
    'Minimal',
  ];

  List<Map<String, dynamic>> get _filteredLookbookItems {
    if (_selectedCategoryIndex == 0) return _lookbookItems;
    final selected = _categories[_selectedCategoryIndex].toLowerCase();
    return _lookbookItems.where((item) {
      final cat = (item['category'] ?? item['styleCategory'] ?? '').toString().toLowerCase();
      final tag = (item['tag'] ?? '').toString().toLowerCase();
      final sticker = (item['sticker'] ?? '').toString().toLowerCase();
      final title = (item['title'] ?? '').toString().toLowerCase();
      final combined = '$cat $tag $sticker $title';

      if (selected.contains('streetwear')) return combined.contains('street');
      if (selected.contains('editorial')) {
        return combined.contains('editor') ||
            combined.contains('high') ||
            combined.contains('chic') ||
            combined.contains('office') ||
            combined.contains('blazer');
      }
      if (selected.contains('y2k')) return combined.contains('y2k') || combined.contains('rave') || combined.contains('pop');
      if (selected.contains('minimal')) {
        return combined.contains('minimal') ||
            combined.contains('relax') ||
            combined.contains('clean') ||
            combined.contains('trench') ||
            combined.contains('standing');
      }
      return combined.contains(selected);
    }).toList();
  }

  List<Map<String, dynamic>> _lookbookItems = [
    {
      'title': 'Minimal Trench • SS26',
      'category': 'Minimal',
      'styleCategory': 'MINIMAL',
      'creatorInfo': 'Maya Trần • 3 Items',
      'stylistAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
      'image': 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=80',
      'tag': '#Minimal',
      'sticker': 'MINIMAL',
      'pose': 'Dáng đứng thẳng thanh lịch (Sleek Standing)',
      'ambientGlow': const Color(0x3DFB923C),
      'matchScore': '98% Match',
      'landmarks': '33 Keypoints',
      'poseLandmarksJson': {
        'poseType': 'NATURAL_STANDING',
        'leftElbow': 158.0,
        'rightElbow': 158.0,
        'leftShoulder': 28.0,
        'rightShoulder': 28.0,
        'leftHip': 174.0,
        'rightHip': 175.0,
      },
      'affiliateProducts': [
        {'name': 'Oversized Wool Trench', 'brand': 'Lemaire', 'price': '1.450.000₫'},
        {'name': 'Minimalist Silk Knit', 'brand': 'Jil Sander', 'price': '520.000₫'},
        {'name': 'Square Toe Leather Mules', 'brand': 'The Row', 'price': '780.000₫'},
      ],
    },
    {
      'title': 'Urban Casual Denim • AW26',
      'category': 'Streetwear',
      'styleCategory': 'STREETWEAR',
      'creatorInfo': 'Linh Đan • 3 Items',
      'stylistAvatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
      'image': 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?auto=format&fit=crop&w=800&q=80',
      'tag': '#Streetwear',
      'sticker': 'STREETWEAR',
      'pose': 'Dáng đứng 1 tay đút túi (Pocket Stance)',
      'ambientGlow': const Color(0x38F43F5E),
      'matchScore': '97% Match',
      'landmarks': '33 Keypoints',
      'poseLandmarksJson': {
        'poseType': 'ONE_HAND_POCKET',
        'leftElbow': 95.0,
        'rightElbow': 155.0,
        'leftShoulder': 45.0,
        'rightShoulder': 30.0,
        'leftHip': 174.0,
        'rightHip': 175.0,
      },
      'affiliateProducts': [
        {'name': 'Washed Denim Jacket', 'brand': 'Diesel', 'price': '920.000₫'},
        {'name': 'Cotton Cargo Pants', 'brand': 'Stussy', 'price': '580.000₫'},
        {'name': 'Chunky Sneakers', 'brand': 'Eytys', 'price': '650.000₫'},
      ],
    },
    {
      'title': 'Clean Tailoring Blazer • Minimal',
      'category': 'Editorial',
      'styleCategory': 'EDITORIAL',
      'creatorInfo': 'Maya Trần • 2 Items',
      'stylistAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
      'image': 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=800&q=80',
      'tag': '#Editorial',
      'sticker': 'EDITORIAL',
      'pose': 'Dáng đứng thẳng vai ngang (Classic Straight)',
      'ambientGlow': const Color(0x3810B981),
      'matchScore': '99% Match',
      'landmarks': '33 Keypoints',
      'poseLandmarksJson': {
        'poseType': 'EDITORIAL_STRAIGHT',
        'leftElbow': 155.0,
        'rightElbow': 155.0,
        'leftShoulder': 32.0,
        'rightShoulder': 32.0,
        'leftHip': 174.0,
        'rightHip': 175.0,
      },
      'affiliateProducts': [
        {'name': 'Double-Breasted Beige Blazer', 'brand': 'Zara', 'price': '890.000₫'},
        {'name': 'Straight-Fit Ivory Trousers', 'brand': 'Mango', 'price': '490.000₫'},
      ],
    },
    {
      'title': 'Summer Resort Linen • Sunlit Breeze',
      'category': 'Editorial',
      'styleCategory': 'EDITORIAL',
      'creatorInfo': 'Maya Trần • 3 Items',
      'stylistAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
      'image': 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=800&q=80',
      'tag': '#ResortBeach',
      'sticker': 'SUMMER',
      'pose': 'Dáng đứng dạo biển đón nắng (Sunlit Stance)',
      'ambientGlow': const Color(0x383B82F6),
      'matchScore': '96% Match',
      'landmarks': '33 Keypoints',
      'poseLandmarksJson': {
        'poseType': 'RESORT_BEACH',
        'leftElbow': 85.0,
        'rightElbow': 150.0,
        'leftShoulder': 70.0,
        'rightShoulder': 32.0,
        'leftHip': 172.0,
        'rightHip': 174.0,
      },
      'affiliateProducts': [
        {'name': 'Camp Collar Linen Shirt', 'brand': 'Massimo Dutti', 'price': '750.000₫'},
        {'name': 'Drawstring Linen Shorts', 'brand': 'Uniqlo', 'price': '390.000₫'},
        {'name': 'Polarized Sunglasses', 'brand': 'Ray-Ban', 'price': '1.250.000₫'},
      ],
    },
    {
      'title': 'Monochrome Street Minimalist',
      'category': 'Streetwear',
      'styleCategory': 'STREETWEAR',
      'creatorInfo': 'Linh Đan • 2 Items',
      'stylistAvatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
      'image': 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80',
      'tag': '#Streetwear',
      'sticker': 'STREETWEAR',
      'pose': 'Dáng đứng thả lỏng 2 tay (Relaxed Standing)',
      'ambientGlow': const Color(0x38A855F7),
      'matchScore': '98% Match',
      'landmarks': '33 Keypoints',
      'poseLandmarksJson': {
        'poseType': 'MONOCHROME_STREET',
        'leftElbow': 152.0,
        'rightElbow': 150.0,
        'leftShoulder': 34.0,
        'rightShoulder': 34.0,
        'leftHip': 172.0,
        'rightHip': 174.0,
      },
      'affiliateProducts': [
        {'name': 'Boxy Heavyweight Tee', 'brand': 'Fear of God', 'price': '650.000₫'},
        {'name': 'Wide-Leg Parachute Pants', 'brand': 'Zara', 'price': '520.000₫'},
      ],
    },
    {
      'title': 'Y2K Pop Cargo Flare • 2026',
      'category': 'Y2K Pop',
      'styleCategory': 'Y2K POP',
      'creatorInfo': 'Linh Đan • 2 Items',
      'stylistAvatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
      'image': 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=800&q=80',
      'tag': '#Y2KPop',
      'sticker': 'Y2K POP',
      'pose': 'Dáng đứng chạm túi quần (Casual Pocket)',
      'ambientGlow': const Color(0x38F43F5E),
      'matchScore': '95% Match',
      'landmarks': '33 Keypoints',
      'poseLandmarksJson': {
        'poseType': 'Y2K_POCKET',
        'leftElbow': 100.0,
        'rightElbow': 155.0,
        'leftShoulder': 40.0,
        'rightShoulder': 28.0,
        'leftHip': 172.0,
        'rightHip': 174.0,
      },
      'affiliateProducts': [
        {'name': 'Cropped Zip-Up Hoodie', 'brand': 'Bershka', 'price': '450.000₫'},
        {'name': 'Cargo Flare Pants', 'brand': 'Diesel', 'price': '880.000₫'},
      ],
    },
  ];

  void _openCamera([Map<String, dynamic>? item]) {
    if (item != null) {
      LookbookProvider.instance.selectLookbookForCamera(item);
    }
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
          budgetVnd: 10000,
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
                          AppLanguageController.instance.t.discoveryCuratedOutfits,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${_filteredLookbookItems.length} ${AppLanguageController.instance.t.discoveryLooksReady}',
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
    final isVi = AppLanguageController.instance.isVietnamese;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isVi ? 'Chào, Alex' : 'Hey, Alex',
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
              isVi ? 'Thử đồ ảo & Xưởng Tạo Dáng AI' : 'Virtual Try-On & AI Pose Atelier',
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
    final isVi = AppLanguageController.instance.isVietnamese;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            isVi ? 'Khám Phá & Khớp Dáng ' : 'Explore & Match Your Next ',
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
                isVi ? 'Chuẩn Mẫu' : 'Iconic',
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
            isVi ? ' Của Bạn.' : ' Pose.',
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
                        AppLanguageController.instance.isVietnamese
                            ? 'NHANH HƠN 50%'
                            : '50% FASTER FIT',
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
                      AppLanguageController.instance.isVietnamese
                          ? 'Định Hình Phong Cách\nThường Ngày.'
                          : 'Elevate Your\nEveryday Style.',
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
                          AppLanguageController.instance.t.discoveryTryAiCameraBtn,
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
    final t = AppLanguageController.instance.t;
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
                  t.isVi ? 'PHỐI ĐỒ CÁ NHÂN 1-KÈM-1' : '1-ON-1 PERSONAL STYLING',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coralOrange,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                t.isVi ? 'BẢO VỆ KÝ QUỸ' : 'ESCROW PROTECTED',
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
            t.discoveryCustomStylingTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.discoveryCustomStylingSubtitle,
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
                t.discoveryRequestStylingBtn,
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
    final isVi = AppLanguageController.instance.isVietnamese;
    final viCategories = const [
      'Tất cả',
      'Streetwear',
      'Editorial',
      'Y2K Pop',
      'Minimal',
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final label = isVi ? viCategories[index] : _categories[index];

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
    final items = _filteredLookbookItems;
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.hairlineBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome_mosaic, color: Colors.black26, size: 36),
            const SizedBox(height: 12),
            Text(
              AppLanguageController.instance.isVietnamese
                  ? 'Chưa có Lookbook cho phong cách này'
                  : 'No Lookbooks found for this style',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppLanguageController.instance.isVietnamese
                  ? 'Hãy chọn "Tất cả" để xem toàn bộ dáng mẫu'
                  : 'Select "All Looks" to browse all poses',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    final leftItems = <Map<String, dynamic>>[];
    final rightItems = <Map<String, dynamic>>[];
    for (int i = 0; i < items.length; i++) {
      if (i % 2 == 0) {
        leftItems.add(items[i]);
      } else {
        rightItems.add(items[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          child: Column(
            children: [
              for (int i = 0; i < leftItems.length; i++) ...[
                if (i > 0) const SizedBox(height: 18),
                _buildMasonryCardItem(leftItems[i], i * 2),
              ],
            ],
          ),
        ),

        const SizedBox(width: 14),

        // Right Column (Offset 24px lower for editorial stagger effect)
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 24),
              for (int i = 0; i < rightItems.length; i++) ...[
                if (i > 0) const SizedBox(height: 18),
                _buildMasonryCardItem(
                  rightItems[i],
                  i * 2 + 1,
                  isFeatured: i == 0,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Single Masonry Lookbook Card Item with Ambient Colored Glow & Frosted Stickers
  Widget _buildMasonryCardItem(Map<String, dynamic> item, int index, {bool isFeatured = false}) {
    final String itemKey = (item['id'] ?? item['title'] ?? index).toString();
    final isLiked = _likedItemKeys.contains(itemKey);

    return SpringInteractiveCard(
      scaleFactor: 0.97,
      onTap: () => _openCamera(item),
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
                            _likedItemKeys.remove(itemKey);
                          } else {
                            _likedItemKeys.add(itemKey);
                          }
                        });
                        final lbId = item['id']?.toString();
                        if (lbId != null && lbId.isNotEmpty) {
                          LookbookProvider.instance.toggleLike(lbId);
                        }
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
                  Builder(
                    builder: (_) {
                      final rawTitle = item['title'] as String? ?? '';
                      final titleParts = rawTitle.split('•');
                      final mainTitle = titleParts[0].trim();
                      final seasonBadge = titleParts.length > 1 ? titleParts[1].trim() : 'AW26';

                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              mainTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              seasonBadge,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE11D48),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  // Creator & Affiliate Items row: Avatar + Stylist name + Items pill (No •)
                  Builder(
                    builder: (_) {
                      final rawCreator = item['creatorInfo'] as String? ?? 'Maya Trần • 3 Items';
                      final creatorParts = rawCreator.split('•');
                      final stylistName = creatorParts[0].trim();
                      final rawCount = creatorParts.length > 1 ? creatorParts[1].trim() : '3 Items';
                      final itemsCount = AppLanguageController.instance.isVietnamese
                          ? rawCount.replaceAll('Items', 'món đồ')
                          : rawCount.replaceAll('món đồ', 'Items');

                      return Row(
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
                              stylistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F5),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFE4E4E7), width: 0.8),
                            ),
                            child: Text(
                              itemsCount,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // ONE FULL-WIDTH CAMERA BUTTON AT THE BOTTOM OF THE CARD
                  SpringInteractiveCard(
                    scaleFactor: 0.95,
                    onTap: () => _openCamera(item),
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
                        AppLanguageController.instance.t.discoveryTryAiCameraBtn,
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
