import 'package:flutter/material.dart';

class AppTheme {
  // Futuristic White Glass Palette
  static const Color glassWhite = Color(0xF2F8FAFC); // 95% opacity white slate base
  static const Color glassPanel = Color(0xBFF8FAFC); // 75% opacity white glass
  static const Color glassCard = Color(0xCCFFFFFF);  // 80% frosted pure white
  static const Color glassHover = Color(0x333B82F6); // Soft blue glass hover tint

  // Border Strokes
  static const Color glassBorder = Color(0x80E2E8F0); // Subtle 50% border stroke
  static const Color activeBorder = Color(0x663B82F6); // Active glowing blue border

  // Electric Blue Accents & Highlights
  static const Color electricBlue = Color(0xFF2563EB); // Vivid primary blue
  static const Color electricBlueLight = Color(0xFF3B82F6); // Glow & hover blue
  static const Color electricBlueDark = Color(0xFF1D4ED8);
  static const Color electricBlueGlow = Color(0x4D3B82F6); // 30% glow shadow

  // Typography & Icons (Deep Slate / Charcoal for extreme legibility)
  static const Color textPrimary = Color(0xFF0F172A); // Deep slate
  static const Color textSecondary = Color(0xFF64748B); // Muted slate
  static const Color textDisabled = Color(0xFF94A3B8);

  // Background
  static const Color backgroundDark = Color(0xFF090D16); // Cinema backdrop for viewport

  // Shadows
  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: electricBlueLight.withOpacity(0.12),
      blurRadius: 30,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> buttonGlow = [
    BoxShadow(
      color: electricBlue.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: 'Segoe UI',
      colorScheme: const ColorScheme.light(
        primary: electricBlue,
        secondary: electricBlueLight,
        surface: glassPanel,
        onSurface: textPrimary,
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 20),
    );
  }
}
