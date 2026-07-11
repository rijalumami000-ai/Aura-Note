import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Theme Colors
  static const Color background = Color(0xFF0F0F1A); // Deep cosmic dark navy
  static const Color surface = Color(0xFF181829);    // Glassmorphic surface dark blue-grey
  static const Color accent = Color(0xFF8A2BE2);     // Cosmic purple accent
  static const Color textPrimary = Color(0xFFE2E2E9);
  static const Color textSecondary = Color(0xFF9090A0);

  // Category Color Map (Auras)
  static const Map<String, List<Color>> categoryGradients = {
    'Pekerjaan': [Color(0xFF00F2FE), Color(0xFF4FACFE)],  // Cyan to Blue
    'Pribadi': [Color(0xFFF76B1C), Color(0xFFFAD961)],    // Orange to Yellow
    'Ide': [Color(0xFFB19FFB), Color(0xFF8A2BE2)],        // Neon Violet/Purple
    'Keuangan': [Color(0xFF00FF87), Color(0xFF60EFFF)],   // Green to Cyan
    'Gaya Hidup': [Color(0xFFFF9A9E), Color(0xFFFECFEF)], // Pastel Pink
  };

  static List<Color> getGradientForCategory(String category) {
    return categoryGradients[category] ?? [accent, accent.withOpacity(0.5)];
  }

  static Color getColorForCategory(String category) {
    return getGradientForCategory(category).first;
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: accent,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF3B82F6),
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }

  // Glassmorphic Decoration Helper
  static BoxDecoration glassDecoration({
    required Color auraColor,
    double opacity = 0.08,
    double blur = 16.0,
    double borderRadius = 20.0,
    bool showGlow = false,
  }) {
    return BoxDecoration(
      color: surface.withOpacity(0.75),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: showGlow ? auraColor.withOpacity(0.6) : auraColor.withOpacity(0.2),
        width: showGlow ? 1.8 : 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
        if (showGlow)
          BoxShadow(
            color: auraColor.withOpacity(0.25),
            blurRadius: 18,
            spreadRadius: -2,
          ),
      ],
    );
  }
  // Preset Gradasi Sampul Premium (AuraCovers)
  static const Map<String, List<Color>> coverGradients = {
    'purple_sunset': [Color(0xFFFF512F), Color(0xFFDD2476)],
    'aurora_borealis': [Color(0xFF02AAB0), Color(0xFF00CDAC)],
    'cosmic_nebula': [Color(0xFFFF007F), Color(0xFF7F00FF)],
    'electric_sian': [Color(0xFF00F2FE), Color(0xFF4FACFE)],
    'fire_fusion': [Color(0xFFF12711), Color(0xFFF5AF19)],
  };

  static LinearGradient? getCoverGradient(String? coverName) {
    if (coverName == null) return null;
    final colors = coverGradients[coverName];
    if (colors != null) {
      return LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    // Fallback if hex color value
    try {
      final colorVal = int.parse(coverName.replaceFirst('#', '0xFF'));
      final Color color = Color(colorVal);
      return LinearGradient(colors: [color, color]);
    } catch (_) {
      return null;
    }
  }
}
