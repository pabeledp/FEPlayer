import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<FEPlayerController>();

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
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Configure sleep timer, storage location, and hardware shortcuts",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),

          const SizedBox(height: 24),

          // 1. Sleep Timer Card (NEW)
          GlassCard(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.95),
            borderColor: const Color(0xFFE2E8F0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bedtime_rounded, color: Color(0xFF2563EB), size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Playback Sleep Timer",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    if (player.sleepTimerRemaining != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: AppTheme.buttonGlow,
                        ),
                        child: Text(
                          "${(player.sleepTimerRemaining!.inSeconds / 60).ceil()} min remaining",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Automatically shut down media playback after selected duration",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SettingsTimerPill(
                      label: "Off",
                      isSelected: player.sleepTimerOption == SleepTimerOption.off,
                      onTap: () => player.setSleepTimer(SleepTimerOption.off),
                    ),
                    _SettingsTimerPill(
                      label: "15 min",
                      isSelected: player.sleepTimerOption == SleepTimerOption.min15,
                      onTap: () => player.setSleepTimer(SleepTimerOption.min15),
                    ),
                    _SettingsTimerPill(
                      label: "30 min",
                      isSelected: player.sleepTimerOption == SleepTimerOption.min30,
                      onTap: () => player.setSleepTimer(SleepTimerOption.min30),
                    ),
                    _SettingsTimerPill(
                      label: "45 min",
                      isSelected: player.sleepTimerOption == SleepTimerOption.min45,
                      onTap: () => player.setSleepTimer(SleepTimerOption.min45),
                    ),
                    _SettingsTimerPill(
                      label: "60 min",
                      isSelected: player.sleepTimerOption == SleepTimerOption.min60,
                      onTap: () => player.setSleepTimer(SleepTimerOption.min60),
                    ),
                    _SettingsTimerPill(
                      label: "End of Track",
                      isSelected: player.sleepTimerOption == SleepTimerOption.endOfTrack,
                      onTap: () => player.setSleepTimer(SleepTimerOption.endOfTrack),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Storage Location Card
          GlassCard(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.95),
            borderColor: const Color(0xFFE2E8F0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.folder_special_rounded, color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Media Storage Location",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.folder_rounded, size: 16, color: Color(0xFF475569)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "~/Documents/FEPlayer_Media/",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        "Default",
                        style: TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Playback Engine Card
          GlassCard(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.95),
            borderColor: const Color(0xFFE2E8F0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.speed_rounded, color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Hardware Video Acceleration",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("libmpv Engine (60fps Ultra Low Latency)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    Text("Active", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.green)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Dual Audio Track Passthrough", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    Text("Enabled", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Keyboard Shortcuts Cheatsheet Card
          GlassCard(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.95),
            borderColor: const Color(0xFFE2E8F0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.keyboard_rounded, color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Keyboard Shortcuts",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _shortcutRow("Space", "Play / Pause Toggle"),
                _shortcutRow("Up / Down Arrow", "Volume ±5% (HUD Display)"),
                _shortcutRow("Left / Right Arrow", "Seek ±10 seconds"),
                _shortcutRow("M", "Mute / Unmute"),
                _shortcutRow("L", "Toggle Media Library Sidebar"),
                _shortcutRow("F or F11", "Toggle Fullscreen Mode"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5. App Branding & Version
          Center(
            child: Column(
              children: [
                Image.asset('assets/images/fe_player_banner.png', height: 60, fit: BoxFit.contain),
                const SizedBox(height: 8),
                const Text(
                  "Version 1.0.0 (Release)",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
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
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTimerPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SettingsTimerPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.accentGradient : null,
          color: isSelected ? null : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00F2FE) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? AppTheme.cyanGlow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
