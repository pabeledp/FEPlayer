import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            "Settings & Preferences",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Configure download storage, playback engine, and shortcuts",
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),

          const SizedBox(height: 24),

          // 1. Storage Location Card
          GlassCard(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.folder_special_rounded, color: AppTheme.electricBlue, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Media Storage Location",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.folder_rounded, size: 16, color: AppTheme.textSecondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "~/Documents/FEPlayer_Media/",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        "Default",
                        style: TextStyle(fontSize: 11, color: AppTheme.electricBlue, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Playback Engine Card
          GlassCard(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.14),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.speed_rounded, color: AppTheme.neonCyan, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Hardware Video Acceleration",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("libmpv Engine (60fps Ultra Low Latency)", style: TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                    Text("Active", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Dual Audio Track Passthrough", style: TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                    Text("Enabled", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.electricBlue)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Keyboard Shortcuts Cheatsheet Card
          GlassCard(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.keyboard_rounded, color: AppTheme.electricBlue, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Keyboard Shortcuts",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _shortcutRow("Space", "Play / Pause Toggle"),
                _shortcutRow("Up / Down Arrow", "Volume ±5% (HUD Display)"),
                _shortcutRow("Left / Right Arrow", "Seek ±5 seconds"),
                _shortcutRow("M", "Mute / Unmute"),
                _shortcutRow("L", "Toggle Media Library Sidebar"),
                _shortcutRow("F or F11", "Toggle Fullscreen Mode"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. App Branding & Version
          Center(
            child: Column(
              children: [
                Image.asset('assets/icons/app_logo.png', height: 48),
                const SizedBox(height: 8),
                const Text(
                  "FE Player v1.0.0",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Clean Futuristic Multimedia Organizer",
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _shortcutRow(String key, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
