import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PortfolioTheme {
  // Brand Colors from text.txt
  static const Color primary = Color(0xFF2563EB);      // Primary Brand Blue
  static const Color secondary = Color(0xFF1E293B);    // Secondary Navy Slate
  static const Color accent = Color(0xFF06B6D4);       // Accent Cyan
  
  // Backgrounds
  static const Color bgLight = Color(0xFFF8FAFC);      // Light mode background
  static const Color bgDark = Color(0xFF0F172A);       // Dark mode background
  
  // Surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  
  // Border colors
  static const Color borderLight = Color(0xEAEAEAFF);
  static const Color borderDark = Color(0x1EFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphic Shadows
  static List<BoxShadow> premiumShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.06),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: primary.withOpacity(0.03),
        blurRadius: 30,
        offset: const Offset(0, 0),
        spreadRadius: 2,
      ),
    ];
  }

  static List<BoxShadow> get hoverGlowShadow => [
    BoxShadow(
      color: primary.withOpacity(0.25),
      blurRadius: 25,
      offset: const Offset(0, 8),
      spreadRadius: 1,
    ),
    BoxShadow(
      color: accent.withOpacity(0.15),
      blurRadius: 15,
      offset: const Offset(0, 2),
    ),
  ];

  // Theme Creator: Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        background: bgDark,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      dividerColor: borderDark,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF94A3B8), // slate-400
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF94A3B8), // slate-400
          height: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x0CFFFFFF),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14),
        labelStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  // Theme Creator: Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        background: bgLight,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      dividerColor: borderLight,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: secondary,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: secondary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: secondary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF475569), // slate-600
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF475569), // slate-600
          height: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: secondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
        labelStyle: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }
}
