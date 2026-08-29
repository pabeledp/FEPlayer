import 'package:flutter/material.dart';

class AppTheme {
  // Apple-Inspired High-Contrast Glassmorphic Palette
  static const Color glassWhite = Color(0xF7FFFFFF); // 97% pure crisp white container
  static const Color glassPanel = Color(0xF2FFFFFF); // 95% opacity frosted glass
  static const Color glassCard = Color(0xF0FFFFFF);  // 94% opacity solid light card
  static const Color glassCardDark = Color(0xF00F172A); // 94% opacity dark glass container
  static const Color glassHover = Color(0x3300F2FE); // Soft neon cyan glass hover

  // Crisp Hairline Borders (High contrast)
  static const Color glassBorder = Color(0xFFE2E8F0); // Crisp light border
  static const Color glassBorderMedium = Color(0xFFCBD5E1); // Slightly darker border for cards
  static const Color activeBorder = Color(0xFF00F2FE); // Glowing neon cyan border

  // Accent Colors: Electric Blue (#2563EB / #4FACFE) to Neon Cyan (#00F2FE)
  static const Color electricBlue = Color(0xFF2563EB); // Vibrant Electric Blue
  static const Color electricBlueLight = Color(0xFF60A5FA);
  static const Color electricBlueDark = Color(0xFF1D4ED8);
  static const Color neonCyan = Color(0xFF00F2FE);
  static const Color vibrantBlue = Color(0xFF2563EB);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF00D2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FAFC),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography & Text (High Contrast & Legibility)
  static const Color textPrimary = Color(0xFF0F172A); // Jet Black / Deep Charcoal
  static const Color textSecondary = Color(0xFF334155); // Dark Slate (High contrast)
  static const Color textMuted = Color(0xFF64748B); // Slate Muted
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFFFFFFF);

  // Background Scaffolds
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color backgroundLight = Color(0xFFF1F5F9); // Clean Apple Slate Light

  // Ambient Glass Shadows
  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF2563EB).withOpacity(0.06),
      blurRadius: 25,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> buttonGlow = [
    BoxShadow(
      color: const Color(0xFF2563EB).withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cyanGlow = [
    BoxShadow(
      color: const Color(0xFF00F2FE).withOpacity(0.45),
      blurRadius: 18,
      offset: const Offset(0, 2),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'SF Pro Display',
      colorScheme: const ColorScheme.light(
        primary: vibrantBlue,
        secondary: neonCyan,
        surface: glassPanel,
        onSurface: textPrimary,
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 20),
    );
  }
}
