import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/brutalist_badge.dart';
import '../widgets/brutalist_button.dart';
import '../widgets/brutalist_card.dart';
import '../widgets/technical_grid_background.dart';
import 'pose_camera_screen.dart';

/// Screen 07: Dispute Resolution & Review Modal (Khiếu nại Hoàn tiền & Đánh giá Uy tín)
/// Upgraded to "Street-Zine Neo-Pop" aesthetic
class DisputeReviewScreen extends StatefulWidget {
  final bool isDisputeMode;

  const DisputeReviewScreen({
    super.key,
    this.isDisputeMode = false,
  });

  @override
  State<DisputeReviewScreen> createState() => _DisputeReviewScreenState();
}

class _DisputeReviewScreenState extends State<DisputeReviewScreen> {
  late bool _isDispute;
  int _selectedRating = 5;
  String _selectedReason = 'Sai lệch ConceptDescription đã thỏa thuận';
  final Set<String> _selectedCompliments = {'ON-POINT STYLE', 'EASY AI POSE'};

  @override
  void initState() {
    super.initState();
    _isDispute = widget.isDisputeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isDispute ? 'Dispute Resolution' : 'Review & Rating',
          style: AppTheme.titleStyle.copyWith(fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BrutalistBadge(
              label: _isDispute ? '⚠️ Escrow Frozen' : '★ Verified Rating',
              backgroundColor: _isDispute ? AppColors.vermilion : AppColors.cyber,
              textColor: _isDispute ? Colors.white : AppColors.ink,
              isMonospace: true,
            ),
          ),
        ],
      ),
      body: TechnicalGridBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
          child: Column(
            children: [
              // Mode Switcher Banner
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.hairlineBorder, width: AppColors.cardBorderWidth),
                  boxShadow: AppColors.chipShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isDispute = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: !_isDispute ? AppColors.primaryGradient : null,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: !_isDispute ? AppColors.buttonShadow : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Chế độ Đánh giá (Review)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: !_isDispute ? Colors.white : AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isDispute = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isDispute ? AppColors.vermilion : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: _isDispute ? AppColors.chipShadow : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Chế độ Khiếu nại (Dispute)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _isDispute ? Colors.white : AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              if (!_isDispute) _buildReviewMode() else _buildDisputeMode(),
            ],
          ),
        ),
      ),
    );
  }

  /// Chế độ A – Đánh giá sau khi hoàn tất Mốc 3 (Thực thể REVIEW)
  Widget _buildReviewMode() {
    return BrutalistCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Rate Your Experience',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.petrol,
                  ),
                ),
              ),
              const BrutalistBadge(
                label: '3 Stages Done',
                backgroundColor: AppColors.warmAmber,
                isMonospace: false,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5 Ngôi sao màu Warm Amber
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNum = index + 1;
              final isFilled = starNum <= _selectedRating;
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = starNum),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.warmAmber : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    boxShadow: isFilled ? AppColors.chipShadow : null,
                  ),
                  child: Icon(
                    Icons.star,
                    color: isFilled ? AppColors.petrol : Colors.black26,
                    size: 26,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          Text(
            'Tags Khen Ngợi Nhanh:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.petrol.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['On-Point Style', 'Easy AI Pose', 'Fast Delivery', 'Accurate Palette'].map((tag) {
              final isSelected = _selectedCompliments.contains(tag);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCompliments.remove(tag);
                    } else {
                      _selectedCompliments.add(tag);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                    tag,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.petrol,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          TextField(
            maxLines: 3,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.petrol,
            ),
            decoration: InputDecoration(
              hintText: 'Nhận xét chi tiết về dịch vụ tư vấn của Stylist Maya Trần...',
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

          const SizedBox(height: 22),

          BrutalistButton(
            text: 'Submit Review & Open AI Camera →',
            backgroundColor: AppColors.warmAmber,
            textColor: AppColors.petrol,
            height: 48,
            icon: Icons.camera_alt,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PoseCameraScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Chế độ B – Mở Tranh chấp khi quá 2 lần sửa (Thực thể DISPUTE)
  Widget _buildDisputeMode() {
    return BrutalistCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Dispute Case #DSP-8452-01',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.petrol,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const BrutalistBadge(
                label: 'Resolution: Open',
                backgroundColor: AppColors.vermilion,
                textColor: Colors.white,
                isMonospace: false,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Hộp thông tin phong tỏa quỹ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.porcelainSmoke,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
              boxShadow: AppColors.chipShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quỹ Ký Quỹ Đang Bị Phong Tỏa:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.petrol,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Frozen Escrow: 70% (1.750.000₫)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.petrol,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chỉ có 30% Mốc 1 (750.000₫) đã giải ngân trước đó.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Lý Do Khiếu Nại (Dispute Reason):',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.petrol,
            ),
          ),
          const SizedBox(height: 10),

          ...[
            'Sai lệch ConceptDescription đã thỏa thuận',
            'Sản phẩm vượt quá ngân sách Budget dự kiến',
            'Stylist trễ hạn bàn giao SLA quá 48h',
            'Link sản phẩm Affiliate bị hỏng / hết hàng',
          ].map((reason) {
            final isSelected = _selectedReason == reason;
            return GestureDetector(
              onTap: () => setState(() => _selectedReason = reason),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.porcelainSmoke : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.vermilion : AppColors.hairlineBorder,
                    width: 1.0,
                  ),
                  boxShadow: isSelected ? AppColors.chipShadow : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 18,
                      color: isSelected ? AppColors.vermilion : AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        reason,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: AppColors.petrol,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 18),

          BrutalistButton(
            text: 'Freeze Escrow & Request Refund',
            backgroundColor: AppColors.vermilion,
            textColor: Colors.white,
            height: 48,
            icon: Icons.shield,
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppColors.cardRadius),
                    side: const BorderSide(color: AppColors.hairlineBorder, width: AppColors.cardBorderWidth),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.vermilion,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Đã đóng băng ký quỹ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.petrol,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    '1.750.000₫ (70% còn lại) đã được phong tỏa để hoàn tiền về tài khoản ngân hàng của khách.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.textMuted,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Đóng',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.petrol,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
