import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import 'glass_card.dart';

class VideoViewport extends StatefulWidget {
  const VideoViewport({super.key});

  @override
  State<VideoViewport> createState() => _VideoViewportState();
}

class _VideoViewportState extends State<VideoViewport> {
  // Gesture drag tracking
  double? _dragStartX;
  double? _dragStartY;
  bool _isHorizontalDrag = false;
  bool _isVerticalLeftDrag = false;
  bool _isVerticalRightDrag = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.toggleControlsVisibility();
      },
      onDoubleTapDown: (details) {
        final screenWidth = size.width;
        final tapX = details.globalPosition.dx;

        if (tapX < screenWidth * 0.45) {
          // Double Tap Left: -10s
          controller.seekRelative(-10);
        } else if (tapX > screenWidth * 0.55) {
          // Double Tap Right: +10s
          controller.seekRelative(10);
        } else {
          // Double Tap Center: Play / Pause
          controller.togglePlayPause();
        }
      },
      onPanStart: (details) {
        _dragStartX = details.globalPosition.dx;
        _dragStartY = details.globalPosition.dy;
        _isHorizontalDrag = false;
        _isVerticalLeftDrag = false;
        _isVerticalRightDrag = false;
        controller.onUserInteraction();
      },
      onPanUpdate: (details) {
        if (_dragStartX == null || _dragStartY == null) return;

        final dx = details.globalPosition.dx - _dragStartX!;
        final dy = details.globalPosition.dy - _dragStartY!;

        // Decide gesture axis if not locked yet
        if (!_isHorizontalDrag && !_isVerticalLeftDrag && !_isVerticalRightDrag) {
          if (dx.abs() > 15 && dx.abs() > dy.abs()) {
            _isHorizontalDrag = true;
            controller.startHorizontalSeek(controller.position);
          } else if (dy.abs() > 15) {
            if (_dragStartX! < size.width * 0.5) {
              _isVerticalLeftDrag = true;
            } else {
              _isVerticalRightDrag = true;
            }
          }
        }

        if (_isHorizontalDrag) {
          // Horizontal Seek: 100px drag = ~20 seconds seek
          final deltaSeconds = (details.delta.dx / size.width) * 90.0;
          controller.updateHorizontalSeek(deltaSeconds);
        } else if (_isVerticalLeftDrag) {
          // Left side: Screen Brightness
          final deltaBrightness = -details.delta.dy / 250.0;
          controller.adjustBrightness(deltaBrightness);
        } else if (_isVerticalRightDrag) {
          // Right side: Audio Volume
          final deltaVolume = -details.delta.dy / 250.0;
          controller.adjustVolume(deltaVolume);
        }
      },
      onPanEnd: (details) {
        if (_isHorizontalDrag) {
          controller.endHorizontalSeek();
        }
        _dragStartX = null;
        _dragStartY = null;
        _isHorizontalDrag = false;
        _isVerticalLeftDrag = false;
        _isVerticalRightDrag = false;
        // Start 3.5s inactivity countdown after gesture completes
        controller.onUserInteraction();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Hardware-Accelerated Video Surface
          Container(
            color: Colors.black,
            child: Center(
              child: Video(
                controller: controller.videoController,
                controls: NoVideoControls,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 2. Play / Pause Center Flash Animation
          if (controller.showPlayPauseOverlay)
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: controller.showPlayPauseOverlay ? 1.0 : 0.0,
                child: GlassCard(
                  padding: const EdgeInsets.all(22),
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.black.withOpacity(0.4),
                  borderColor: AppTheme.neonCyan.withOpacity(0.4),
                  child: Icon(
                    controller.isOverlayPlayIcon
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),

          // 3. Double-Tap Seek Feedback Badges (-10s / +10s)
          if (controller.showSeekLeftFeedback)
            Positioned(
              left: 40,
              top: size.height * 0.4,
              child: _buildSeekFeedbackBadge(isLeft: true),
            ),
          if (controller.showSeekRightFeedback)
            Positioned(
              right: 40,
              top: size.height * 0.4,
              child: _buildSeekFeedbackBadge(isLeft: false),
            ),

          // 4. Horizontal Seek Scrubbing Preview Badge
          if (controller.isDraggingSeek)
            Center(
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xE60F172A),
                borderColor: AppTheme.neonCyan.withOpacity(0.5),
                shadows: AppTheme.cyanGlow,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fast_forward_rounded, color: AppTheme.neonCyan, size: 24),
                    const SizedBox(height: 6),
                    Text(
                      "${controller.formatDuration(controller.dragSeekTarget)} / ${controller.formatDuration(controller.duration)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Left Vertical Screen Brightness Slider HUD
          Positioned(
            left: 20,
            top: size.height * 0.28,
            bottom: size.height * 0.28,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: controller.showBrightnessHud ? 1.0 : 0.0,
              child: _buildVerticalSliderHud(
                icon: Icons.brightness_6_rounded,
                value: controller.brightness,
                label: "${(controller.brightness * 100).toInt()}%",
              ),
            ),
          ),

          // 6. Right Vertical Audio Volume Slider HUD
          Positioned(
            right: 20,
            top: size.height * 0.28,
            bottom: size.height * 0.28,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: controller.showVolumeHud ? 1.0 : 0.0,
              child: _buildVerticalSliderHud(
                icon: controller.isMuted
                    ? Icons.volume_off_rounded
                    : (controller.volume > 0.5
                        ? Icons.volume_up_rounded
                        : Icons.volume_down_rounded),
                value: controller.isMuted ? 0.0 : controller.volume,
                label: controller.isMuted
                    ? "Muted"
                    : "${(controller.volume * 100).toInt()}%",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeekFeedbackBadge({required bool isLeft}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      borderRadius: BorderRadius.circular(24),
      color: Colors.black.withOpacity(0.55),
      borderColor: AppTheme.neonCyan.withOpacity(0.4),
      shadows: AppTheme.cyanGlow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLeft ? Icons.replay_10_rounded : Icons.forward_10_rounded,
            color: AppTheme.neonCyan,
            size: 36,
          ),
          const SizedBox(height: 4),
          Text(
            isLeft ? "-10 sec" : "+10 sec",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalSliderHud({
    required IconData icon,
    required double value,
    required String label,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xD90F172A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppTheme.neonCyan, size: 18),
              const SizedBox(height: 10),
              // Vertical Liquid Bar
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      heightFactor: value.clamp(0.0, 1.0),
                      child: Container(
                        width: 6,
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: AppTheme.cyanGlow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
