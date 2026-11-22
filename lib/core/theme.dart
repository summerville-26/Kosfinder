import 'package:flutter/material.dart';

/// Palet warna utama aplikasi KosFinder dengan konsep Modern Green & White.
class AppColors {
  static const Color primary = Color(0xFF059669); // Emerald 600
  static const Color primaryDark = Color(0xFF047857); // Emerald 700
  static const Color primaryLight = Color(0xFFECFDF5); // Emerald 50
  static const Color primarySurface = Color(0xFFF0FDF4); // Green 50
  static const Color accent = Color(0xFF10B981); // Emerald 500

  static const Color background = Color(0xFFF8FAFC); // Slate 50 lembut
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate 100

  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color success = Color(0xFF16A34A); // Green 600
}

/// Konfigurasi tema dan gaya aplikasi KosFinder.
class AppTheme {
  // Alias palet warna
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color primarySurface = AppColors.primarySurface;
  static const Color accent = AppColors.accent;

  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;

  static const Color textDark = AppColors.textPrimary;
  static const Color textMedium = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;
  static const Color textLight = AppColors.textMuted;

  static const Color border = AppColors.border;
  static const Color borderLight = AppColors.borderLight;

  static const Color redLight = Color(0xFFFEF2F2);
  static const Color redBorder = Color(0xFFFECACA);
  static const Color redText = AppColors.error;

  // Bayangan Halus Modern (Soft Elevation)
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];

  /// Mengembalikan ThemeData aplikasi KosFinder
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryLight,
        onPrimaryContainer: primaryDark,
        secondary: accent,
        surface: surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: redText),
        ),
        labelStyle: const TextStyle(color: textMuted, fontSize: 14),
        hintStyle: const TextStyle(color: textLight, fontSize: 14),
      ),
    );
  }
}
