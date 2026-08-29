import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import 'glass_card.dart';
import 'timeline_scrubber.dart';
import 'volume_slider.dart';
import 'speed_menu.dart';
import 'audio_subtitle_dialog.dart';

class GlassControlsBar extends StatelessWidget {
  const GlassControlsBar({super.key});

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();

    return GlassCard(
      borderRadius: BorderRadius.circular(20),
      borderWidth: 1.0,
      borderColor: Colors.white.withOpacity(0.22),
      color: const Color(0xE60F172A),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 620;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Scrubbing Timeline Bar
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: TimelineScrubber(),
              ),
              const SizedBox(height: 8),

              // 2. Action Toolbar (Responsive Layout)
              if (isCompact)
                _buildCompactToolbar(context, controller)
              else
                _buildExpandedToolbar(context, controller),
            ],
          );
        },
      ),
    );
  }

  // Mobile / Compact Screen Toolbar
  Widget _buildCompactToolbar(BuildContext context, FEPlayerController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Group: Play + Rewind/Forward + Time
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PlayPauseButton(
              isPlaying: controller.isPlaying,
              onTap: () => controller.togglePlayPause(),
              size: 34,
            ),
            const SizedBox(width: 6),
            _IconButtonGlass(
              icon: Icons.replay_10_rounded,
              tooltip: "Rewind 10s",
              onTap: () => controller.seekRelative(-10),
            ),
            _IconButtonGlass(
              icon: Icons.forward_10_rounded,
              tooltip: "Forward 10s",
              onTap: () => controller.seekRelative(10),
            ),
            const SizedBox(width: 6),
            Text(
              controller.formatDuration(controller.position),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),

        // Right Group: Screen Rotate + Background Play + More Menu + Fullscreen
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Screen Rotate (Portrait <-> Landscape)
            if (_isMobile)
              _IconButtonGlass(
                icon: Icons.screen_rotation_rounded,
                tooltip: "Rotate Screen",
                isActive: controller.isLandscape,
                onTap: () => controller.toggleOrientation(),
              ),

            // Background Audio Playback Toggle
            _IconButtonGlass(
              icon: Icons.headphones_rounded,
              tooltip: "Background Audio Mode",
              isActive: controller.isBackgroundPlaybackEnabled,
              onTap: () {
                controller.toggleBackgroundPlayback();
              },
            ),

            // More Options Popover Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded, size: 20, color: Colors.white),
              padding: EdgeInsets.zero,
              color: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              onSelected: (val) {
                if (val == 'tracks') {
                  AudioSubtitleDialog.show(context);
                } else if (val == 'open') {
                  controller.openFile();
                } else if (val == 'mute') {
                  controller.toggleMute();
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'tracks',
                  child: Row(
                    children: [
                      Icon(Icons.subtitles_rounded, color: AppTheme.neonCyan, size: 18),
                      SizedBox(width: 10),
                      Text("Audio Tracks & Subtitles", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      Icon(Icons.folder_open_rounded, color: AppTheme.electricBlueLight, size: 18),
                      SizedBox(width: 10),
                      Text("Open Local File", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'mute',
                  child: Row(
                    children: [
                      Icon(controller.isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Text(controller.isMuted ? "Unmute Volume" : "Mute Volume", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),

            // Fullscreen Toggle
            _IconButtonGlass(
              icon: controller.isFullscreen
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
              tooltip: "Fullscreen",
              onTap: () => controller.toggleFullscreen(),
            ),
          ],
        ),
      ],
    );
  }

  // Expanded / Desktop Toolbar
  Widget _buildExpandedToolbar(BuildContext context, FEPlayerController controller) {
    return Row(
      children: [
        // 1. Play / Pause Button
        _PlayPauseButton(
          isPlaying: controller.isPlaying,
          onTap: () => controller.togglePlayPause(),
        ),
        const SizedBox(width: 8),

        // 2. Skip Back 10s
        _IconButtonGlass(
          icon: Icons.replay_10_rounded,
          tooltip: "Rewind 10s",
          onTap: () => controller.seekRelative(-10),
        ),
        const SizedBox(width: 4),

        // 2. Skip Forward 10s
        _IconButtonGlass(
          icon: Icons.forward_10_rounded,
          tooltip: "Forward 10s",
          onTap: () => controller.seekRelative(10),
        ),
        const SizedBox(width: 8),

        // 3. Volume Control + Expandable Slider
        const VolumeControl(),
        const SizedBox(width: 10),

        // 4. Monospace Timestamp Display (00:00 / 00:00)
        Text(
          "${controller.formatDuration(controller.position)} / ${controller.formatDuration(controller.duration)}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),

        const Spacer(),

        // 5. Screen Rotate Button
        if (_isMobile) ...[
          _IconButtonGlass(
            icon: Icons.screen_rotation_rounded,
            tooltip: "Rotate Screen",
            isActive: controller.isLandscape,
            onTap: () => controller.toggleOrientation(),
          ),
          const SizedBox(width: 6),
        ],

        // 6. Background Audio Playback Mode
        _IconButtonGlass(
          icon: Icons.headphones_rounded,
          tooltip: "Background Audio Mode",
          isActive: controller.isBackgroundPlaybackEnabled,
          onTap: () {
            controller.toggleBackgroundPlayback();
          },
        ),
        const SizedBox(width: 6),

        // 7. Multi-Audio / Dual Language & Subtitles Selector
        _IconButtonGlass(
          icon: Icons.subtitles_rounded,
          tooltip: "Audio Language & Subtitles",
          onTap: () => AudioSubtitleDialog.show(context),
        ),
        const SizedBox(width: 6),

        // 8. Open File Picker Button
        _IconButtonGlass(
          icon: Icons.folder_open_rounded,
          tooltip: "Open Video File",
          onTap: () => controller.openFile(),
        ),
        const SizedBox(width: 6),

        // 9. Playback Speed Selector Popover
        const SpeedMenu(),
        const SizedBox(width: 6),

        // 10. Fullscreen Toggle (F / F11)
        _IconButtonGlass(
          icon: controller.isFullscreen
              ? Icons.fullscreen_exit_rounded
              : Icons.fullscreen_rounded,
          tooltip: "Fullscreen (F11)",
          onTap: () => controller.toggleFullscreen(),
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final double size;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.onTap,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF00D2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: size * 0.58,
          ),
        ),
      ),
    );
  }
}

class _IconButtonGlass extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  const _IconButtonGlass({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<_IconButtonGlass> createState() => _IconButtonGlassState();
}

class _IconButtonGlassState extends State<_IconButtonGlass> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.isActive
                  ? const Color(0xFF00F2FE).withOpacity(0.25)
                  : (_isHovered
                      ? Colors.white.withOpacity(0.18)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: widget.isActive
                  ? Border.all(color: const Color(0xFF00F2FE), width: 1.2)
                  : (_isHovered
                      ? Border.all(color: Colors.white.withOpacity(0.35), width: 1)
                      : null),
              boxShadow: widget.isActive ? AppTheme.cyanGlow : null,
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 18,
                color: widget.isActive
                    ? const Color(0xFF00F2FE)
                    : (_isHovered ? Colors.white : Colors.white.withOpacity(0.9)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
