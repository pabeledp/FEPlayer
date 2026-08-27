import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import 'glass_container.dart';

class VideoViewport extends StatelessWidget {
  const VideoViewport({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Dark Cinema Canvas
            Container(color: AppTheme.backgroundDark),

            // Video Surface
            if (controller.isInitialized)
              Center(
                child: Video(
                  controller: controller.videoController,
                  controls: NoVideoControls,
                  fit: BoxFit.contain,
                ),
              ),

            // Top-level Gesture zones for Double Taps & Screen Clicks
            Row(
              children: [
                // Left Half: Double-tap rewinds 5s
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      controller.togglePlayPause();
                    },
                    onDoubleTap: () {
                      controller.seekRelative(-5);
                    },
                  ),
                ),
                // Right Half: Double-tap forwards 5s
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      controller.togglePlayPause();
                    },
                    onDoubleTap: () {
                      controller.seekRelative(5);
                    },
                  ),
                ),
              ],
            ),

            // Empty State / VLC-Style Dropzone Card (Visible when nothing is playing)
            if (controller.fileName == "No File Loaded" && !controller.isPlaying)
              Center(
                child: GlassContainer(
                  width: 420,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
                  borderRadius: BorderRadius.circular(24),
                  backgroundColor: AppTheme.glassPanel,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.electricBlue.withOpacity(0.12),
                          border: Border.all(
                            color: AppTheme.electricBlueLight.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: AppTheme.glassShadow,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: AppTheme.electricBlue,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "FE PLAYER",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Drag & drop video here or choose from library",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => controller.openFile(),
                            icon: const Icon(Icons.folder_open_rounded, size: 18),
                            label: const Text(
                              "Open Media",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.electricBlue,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: AppTheme.electricBlue.withOpacity(0.4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () => controller.toggleSidebar(),
                            icon: const Icon(Icons.queue_music_rounded, size: 18),
                            label: const Text(
                              "View Library",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.electricBlue,
                              side: const BorderSide(color: AppTheme.electricBlue, width: 1.5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Animated Play/Pause Feedback Pulse in Center
            if (controller.showPlayPauseOverlay)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: controller.showPlayPauseOverlay ? 1.0 : 0.0,
                child: GlassContainer(
                  width: 76,
                  height: 76,
                  borderRadius: BorderRadius.circular(38),
                  backgroundColor: AppTheme.glassCard,
                  borderColor: AppTheme.electricBlueLight.withOpacity(0.4),
                  borderWidth: 1.5,
                  child: Center(
                    child: Icon(
                      controller.isOverlayPlayIcon
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      color: AppTheme.electricBlue,
                      size: 44,
                    ),
                  ),
                ),
              ),

            // Volume Up/Down On-Screen HUD (Keyboard Up/Down Key feedback)
            if (controller.showVolumeHud)
              Positioned(
                top: 70,
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  borderRadius: BorderRadius.circular(16),
                  backgroundColor: AppTheme.glassCard,
                  borderColor: AppTheme.electricBlueLight.withOpacity(0.4),
                  borderWidth: 1.2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.isMuted || controller.volume == 0
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: AppTheme.electricBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 100,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0x33CBD5E1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: controller.isMuted ? 0.0 : controller.volume,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.electricBlue, AppTheme.electricBlueLight],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${(controller.isMuted ? 0 : (controller.volume * 100)).round()}%",
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Double Tap Rewind Indicator (Left Side)
            if (controller.showSeekLeftFeedback)
              const Positioned(
                left: 40,
                child: _SeekFeedbackBadge(
                  icon: Icons.fast_rewind_rounded,
                  label: "-5s",
                ),
              ),

            // Double Tap Forward Indicator (Right Side)
            if (controller.showSeekRightFeedback)
              const Positioned(
                right: 40,
                child: _SeekFeedbackBadge(
                  icon: Icons.fast_forward_rounded,
                  label: "+5s",
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SeekFeedbackBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SeekFeedbackBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: AppTheme.glassCard,
      borderColor: AppTheme.electricBlueLight.withOpacity(0.4),
      borderWidth: 1.2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.electricBlue, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.electricBlue,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
