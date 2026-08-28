import 'package:flutter/material.dart';

class AppTheme {
  // Apple-Inspired Glassmorphic Palette (Light & Dark Glass)
  static const Color glassWhite = Color(0xF2F8FAFC); // Base container
  static const Color glassPanel = Color(0xCCFFFFFF); // 80% opacity frosted glass
  static const Color glassCard = Color(0x24FFFFFF);  // 14% pure frosted glass overlay
  static const Color glassCardDark = Color(0x1F0F172A);
  static const Color glassHover = Color(0x3300F2FE); // Soft neon cyan glass hover

  // Hairline Glass Edges
  static Color glassBorder = Colors.white.withOpacity(0.22);
  static Color glassBorderLight = const Color(0x40E2E8F0);
  static Color activeBorder = const Color(0x8000F2FE); // Glowing neon cyan border

  // Accent Colors: Electric Blue (#4FACFE) to Neon Cyan (#00F2FE)
  static const Color electricBlue = Color(0xFF4FACFE);
  static const Color electricBlueLight = Color(0xFF60A5FA);
  static const Color electricBlueDark = Color(0xFF1D4ED8);
  static const Color neonCyan = Color(0xFF00F2FE);
  static const Color vibrantBlue = Color(0xFF2563EB);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [electricBlue, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x33FFFFFF),
      Color(0x14FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography & Text
  static const Color textPrimary = Color(0xFF0F172A); // Deep Slate
  static const Color textSecondary = Color(0xFF64748B); // Muted Slate
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFF8FAFC);

  // Background Cinema Backdrop
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color backgroundLight = Color(0xFFF1F5F9);

  // Ambient Glass Shadows
  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: neonCyan.withOpacity(0.08),
      blurRadius: 30,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> buttonGlow = [
    BoxShadow(
      color: electricBlue.withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cyanGlow = [
    BoxShadow(
      color: neonCyan.withOpacity(0.45),
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
