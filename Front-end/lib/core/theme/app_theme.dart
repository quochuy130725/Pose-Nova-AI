import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Street-Zine Neo-Pop Typography & ThemeData
/// Eliminates Playfair Display entirely.
/// - Screen Titles & Hero Headings: Plus Jakarta Sans (ExtraBold w800, tight letter-spacing -0.8)
/// - UI Labels, Buttons & Body: Plus Jakarta Sans (Bold w700 / Medium w500)
/// - Financial IDs, Prices & Percentages: JetBrains Mono (Bold w700)
class AppTheme {
  AppTheme._();

  /// Primary Style for App Bar & Screen Titles
  static TextStyle get titleStyle => GoogleFonts.plusJakartaSans(
        color: AppColors.ink,
        fontWeight: FontWeight.w800,
        fontSize: 18,
        letterSpacing: -0.6,
      );

  /// Display Style for Hero Titles
  static TextStyle get displayStyle => GoogleFonts.plusJakartaSans(
        color: AppColors.ink,
        fontWeight: FontWeight.w900,
        fontSize: 26,
        letterSpacing: -0.8,
      );

  /// Section Headings: Plus Jakarta Sans w800
  static TextStyle get headingStyle => GoogleFonts.plusJakartaSans(
        color: AppColors.ink,
        fontWeight: FontWeight.w800,
        fontSize: 15,
        letterSpacing: -0.4,
      );

  /// Subheading Style: Plus Jakarta Sans w700
  static TextStyle get subheadingStyle => GoogleFonts.plusJakartaSans(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: -0.2,
      );

  /// Body Font: Plus Jakarta Sans w600 / w500
  static TextStyle get bodyStyle => GoogleFonts.plusJakartaSans(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        fontSize: 13,
        height: 1.4,
        letterSpacing: -0.1,
      );

  /// High Fashion Display Font for Currency, Percentages, and ID Codes: Plus Jakarta Sans
  static TextStyle get monoStyle => GoogleFonts.plusJakartaSans(
        color: AppColors.ink,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      );

  /// Primary App ThemeData
  static ThemeData get neoBrutalistTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.electricYellow,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.electricYellow,
        onPrimary: Colors.black,
        secondary: AppColors.cyber,
        onSecondary: Colors.black,
        error: AppColors.disputeCrimson,
        onError: Colors.white,
        surface: AppColors.card,
        onSurface: AppColors.ink,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
          letterSpacing: -0.8,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          letterSpacing: -0.6,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          letterSpacing: -0.5,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: -0.3,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.ink,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          letterSpacing: -0.6,
        ),
        iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: const BorderSide(color: AppColors.hairlineBorder, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coralOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: const Color(0x38FF6B35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide.none,
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
