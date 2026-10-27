import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/brutalist_badge.dart';
import '../widgets/fashion_dock_button.dart';
import '../widgets/technical_grid_background.dart';
import 'escrow_checkout_screen.dart';

/// Screen 03: Styling Brief & AI Stylist Matching
/// Stylofy's stacked overlapping card deck:
/// - Top card: Style chips (#STREET_TECH, #OVERSIZE), 2-line brief input, Pitch Black "✨ GEMINI ENHANCE" pill button with #FFE600 icon
/// - Overlapping Budget Card: Huge "2.500.000đ" JetBrains Mono typography + visual 3-stage node bar (30% —o— 30% —o— 40% in #00E676 and #FFE600)
/// - Recommended Stylist Card: Maya Trần 98% Match
class CreateStylingRequestScreen extends StatefulWidget {
  final String? lookbookTitle;
  final String? stylistName;
  final int? budgetVnd;

  const CreateStylingRequestScreen({
    super.key,
    this.lookbookTitle,
    this.stylistName,
    this.budgetVnd,
  });

  @override
  State<CreateStylingRequestScreen> createState() => _CreateStylingRequestScreenState();
}

class _CreateStylingRequestScreenState extends State<CreateStylingRequestScreen> {
  late final TextEditingController _conceptController;
  String _selectedVibe = '#STREET_TECH';
  bool _isEnhanced = false;

  @override
  void initState() {
    super.initState();
    _conceptController = TextEditingController(
      text: widget.lookbookTitle ?? 'Cyberpunk Streetwear • Oversize Neon',
    );
  }

  void _enhanceBriefWithGemini() {
    setState(() {
      _isEnhanced = true;
      _conceptController.text = 'Cyberpunk Street Tech • Matte Black with Acid Lime Flare • Low Stride';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0D0F0E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 2.2),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.coralOrange, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gemini AI: Brief optimized for 30 FPS Pose Matching!',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _conceptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguageController.instance,
      builder: (context, _) {
        final t = AppLanguageController.instance.t;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: true,
            titleSpacing: 0,
            title: Text(
              'PoseNova Atelier',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 14.0),
                child: BrutalistBadge(
                  label: 'CLIENT BRIEF',
                  backgroundColor: AppColors.electricYellow,
                  isMonospace: true,
                ),
              ),
            ],
          ),
          body: TechnicalGridBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HERO TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.petrol,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.transparent, width: 1.0),
                            ),
                            child: Text(
                              'AW26 • Specification',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: AppColors.warmAmber,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Styling Brief',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.petrol,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ],
                      ),
                      const BrutalistBadge(
                        label: 'AI Matching',
                        backgroundColor: AppColors.warmAmber,
                        isMonospace: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 2. TOP CARD: Style Chips + 2-Line Input + Deep Petrol "✨ Gemini Enhance"
                  _buildConceptCard(),

                  const SizedBox(height: 18),

                  // 3. OVERLAPPING BUDGET CARD: Deep Petrol (#0E4756) Banner with Huge 2.500.000đ in Warm Amber
                  _buildBudgetAndEscrowCard(),

                  const SizedBox(height: 18),

                  // 4. RECOMMENDED STYLIST CARD
                  _buildRecommendedStylistCard(t),
                ],
              ),
            ),
          ),
          // 5. BOTTOM CTA
          bottomNavigationBar: Container(
            color: Colors.transparent,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FashionDockButton(
                  text: t.isVi ? 'Gửi Yêu Cầu Phối Đồ →' : 'Submit Styling Request →',
                  height: 52,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EscrowCheckoutScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Top Card: Style chips, 2-line brief input, and a Deep Petrol "✨ Gemini Enhance" pill button
  Widget _buildConceptCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        border: Border.all(color: AppColors.hairlineBorder, width: AppColors.cardBorderWidth),
        boxShadow: AppColors.softDribbbleShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Concept & Occasion',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.petrol,
                  letterSpacing: -0.2,
                ),
              ),
              if (_isEnhanced)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warmAmber,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.petrol.withValues(alpha: 0.15), width: 1.0),
                  ),
                  child: Text(
                    'AI Optimized',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.petrol,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Style Chips: Street Tech, Oversize, Cyber Pop
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Street Tech', 'Oversize', 'Cyber Pop'].map((vibe) {
              final isSelected = _selectedVibe == vibe;
              return GestureDetector(
                onTap: () => setState(() => _selectedVibe = vibe),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.warmAmber : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected ? AppColors.petrol.withValues(alpha: 0.2) : AppColors.hairlineBorder,
                      width: 1.0,
                    ),
                    boxShadow: isSelected ? AppColors.chipShadow : null,
                  ),
                  child: Text(
                    vibe,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.petrol,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Concise Text Field (Max 2 lines)
          TextField(
            controller: _conceptController,
            maxLines: 2,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.petrol,
              height: 1.35,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: AppColors.porcelainSmoke,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.hairlineBorder, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.hairlineBorder, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.petrol, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Deep Petrol "✨ Gemini Enhance" Pill Button with Warm Amber Icon
          GestureDetector(
            onTap: _enhanceBriefWithGemini,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.petrol,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.petrol, width: 1.0),
                boxShadow: AppColors.buttonShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Gemini Co-pilot Enhance',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.warmAmber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColors.petrol,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Upright Budget Card: Luxurious Sunset Rose-to-Gold Gradient with "2.500.000đ"
  Widget _buildBudgetAndEscrowCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.heroPayoutGradient, // #F9A8D4 -> #FB923C
            borderRadius: BorderRadius.circular(AppColors.cardRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33F43F5E),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Escrow Budget',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1B18).withValues(alpha: 0.75),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '2.500.000đ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E1B18),
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: AppColors.chipShadow,
                    ),
                    child: Text(
                      '100% Secured',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E1B18),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Visual 3-Stage Node Track (30% —o— 30% —o— 40%)
              _build3StageNodeTrack(),
            ],
          ),
        ),

        // Upright #Escrow sticker overlapping top-right corner
        Positioned(
          top: -10,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(999),
              boxShadow: AppColors.buttonShadow,
            ),
            child: Text(
              'Escrow Protected',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Visual 3-Stage Node Track: 3 Pill Blocks + Connected (o---o---o) Line
  Widget _build3StageNodeTrack() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF072731),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12, width: 1.0),
      ),
      child: Column(
        children: [
          // 3 Horizontal Pill Blocks
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.warmAmber,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '30% Draft',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.petrol,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.warmAmber,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '30% Outfit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.petrol,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF144B5B),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '40% Final',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Connected Node Track (30% —o— 30% —o— 40%)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Node 1 (Warm Amber)
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.warmAmber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 10, color: AppColors.petrol),
                ),
                // Line 1-2 (Warm Amber)
                Expanded(
                  child: Container(
                    height: 3,
                    color: AppColors.warmAmber,
                  ),
                ),
                // Node 2 (Warm Amber)
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.warmAmber,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.petrol,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                // Line 2-3
                Expanded(
                  child: Container(
                    height: 3,
                    color: Colors.white24,
                  ),
                ),
                // Node 3 (Locked)
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFF144B5B),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Recommended Stylist Card
  Widget _buildRecommendedStylistCard(AppTranslations t) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        border: Border.all(color: AppColors.hairlineBorder, width: AppColors.cardBorderWidth),
        boxShadow: AppColors.softDribbbleShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended Stylist',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.petrol,
                  letterSpacing: -0.2,
                ),
              ),
              const BrutalistBadge(
                label: '98% Match',
                backgroundColor: AppColors.warmAmber,
                isMonospace: false,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
                      ),
                      backgroundColor: AppColors.petrol,
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.warmAmber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 9,
                        color: AppColors.petrol,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Maya Trần',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.petrol,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warmAmber,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            t.stylistBadge,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.petrol,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '4.9 ★ (128 Reviews) • Top Atelier Stylist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
