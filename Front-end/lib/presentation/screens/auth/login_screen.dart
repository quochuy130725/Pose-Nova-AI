import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/language_switch_pill.dart';
import '../../widgets/technical_grid_background.dart';
import '../client_main_shell.dart';
import '../stylist_main_shell.dart';

/// Screen: Sunset Rose-Pink & Golden-Yellow Authentication (LoginScreen)
/// - Sunset Rose-Pink & Golden-Yellow mesh background
/// - Frosted White card with hairline border & soft shadow
/// - Glossy Coral-Orange "CLIENT LOGIN →" pill button
/// - Warm Espresso "STYLIST STUDIO →" pill button
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLanguageController.instance,
      builder: (context, _) {
        final t = AppLanguageController.instance.t;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: TechnicalGridBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- 1. Top Bar: Stadium Pill + Language Switcher ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
                              boxShadow: AppColors.chipShadow,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.coralOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "PoseNova • Fashion Atelier '26",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.ink,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Language Switcher (Compact VI / EN)
                          const LanguageSwitchPill(compact: true),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // --- Brand Title & Subtitle ---
                      Text(
                        'PoseNova AI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Virtual Try-On & Managed Escrow Styling Atelier',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- 2. AUTH CARD (Frosted White Card) ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.hairlineBorder,
                            width: 1.0,
                          ),
                          boxShadow: AppColors.modalShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Form Heading
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.authCardHeading,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.ink,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.rosePinkSoft,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Atelier Auth',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.coralOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Mock Email Input Field
                            Text(
                              t.authLabelUsername,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8F9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.mail_outline, size: 18, color: AppColors.ink),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'alex.fashionista@posenova.ai',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Mock Password Input Field
                            Text(
                              t.authLabelPassword,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8F9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lock_outline, size: 18, color: AppColors.ink),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '••••••••••••',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2.0,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.visibility_off_outlined,
                                    size: 18,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Divider: "HOẶC CHỌN VAI TRÒ DEMO"
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: AppColors.hairlineBorder, thickness: 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    t.authDividerOrDemo,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: AppColors.hairlineBorder, thickness: 1),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Button 1 (Client Login): Glossy Coral-Orange Pill Button
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ClientMainShell()),
                                );
                              },
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: AppColors.buttonShadow,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.person_outline, size: 18, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Client Login (Alex Đỗ) →',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Button 2 (Stylist Login): Warm Espresso Pill with Golden text
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const StylistMainShell()),
                                );
                              },
                              child: Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                decoration: BoxDecoration(
                                  color: AppColors.ink,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1F000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Stylist Studio (Maya Trần) →',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
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

                      const SizedBox(height: 24),

                      // --- 4. FOOTER SECURITY NOTICE ---
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shield_outlined, size: 14, color: AppColors.coralOrange),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                t.authFooterSecurity,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
