import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual aplikasi JagaWarung — modern, bersih, profesional.
class AppTheme {
  AppTheme._();

  // ── Palet Warna ──
  // Menggunakan warna biru maskapai (Royal/Vibrant Blue) sebagai warna utama
  static const Color primary = Color(0xFF2A5EE0); 
  static const Color primarySoft = Color(0xFFE0E7FF);
  // Warna aksen kontras gelap (seperti tombol hitam/abu tua di aplikasi modern)
  static const Color accent = Color(0xFF1E293B); 
  static const Color accentLight = Color(0xFFCBD5E1);
  static const Color accentSurface = Color(0xFFF8FAFC);

  static const Color bg = Color(0xFFEEF2F6); // Latar belakang abu kebiruan sangat muda
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF8FAFC);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF0F172A);
  static const Color textBody = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF10B981);
  static const Color successSurface = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSurface = Color(0xFFFEE2E2);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Radius dibesarkan mengikuti gaya floating card modern (seperti aplikasi tiket)
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double r32 = 32.0;

  static List<BoxShadow> get shadowSm => [
    BoxShadow(color: const Color(0xFF2A5EE0).withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(color: const Color(0xFF2A5EE0).withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(color: const Color(0xFF2A5EE0).withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
  ];

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(primary: primary, secondary: accent, surface: surface, error: danger),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: textDark, height: 1.2),
        displayMedium: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700, color: textDark, height: 1.2),
        headlineLarge: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700, color: textDark),
        headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        headlineSmall: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        titleLarge: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textDark),
        titleSmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textBody),
        bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: textBody, height: 1.6),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textBody, height: 1.5),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary, // Menggunakan warna utama untuk AppBar
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(r12), borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(r12), borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(r12), borderSide: const BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(r12), borderSide: const BorderSide(color: danger)),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: textMuted),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r24)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
      ),
      dividerTheme: const DividerThemeData(color: borderLight, thickness: 1, space: 1),
    );
  }
}
