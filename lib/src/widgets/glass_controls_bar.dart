import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import 'glass_container.dart';
import 'timeline_scrubber.dart';
import 'volume_slider.dart';
import 'speed_menu.dart';
import 'audio_subtitle_dialog.dart';

class GlassControlsBar extends StatelessWidget {
  const GlassControlsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();

    return GlassContainer(
      borderRadius: BorderRadius.circular(16),
      borderWidth: 1.0,
      borderColor: AppTheme.glassBorder,
      backgroundColor: AppTheme.glassPanel,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrubbing Timeline Bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: TimelineScrubber(),
          ),
          const SizedBox(height: 10),

          // Action Toolbar
          Row(
            children: [
              // 1. Play / Pause Button with Electric Blue Accent
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
              const SizedBox(width: 8),

              // 4. Monospace Timestamp Display (00:00 / 00:00)
              Text(
                "${controller.formatDuration(controller.position)} / ${controller.formatDuration(controller.duration)}",
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),

              const Spacer(),

              // 5. Multi-Audio / Dual Language & Subtitles Selector (NEW)
              _IconButtonGlass(
                icon: Icons.subtitles_rounded,
                tooltip: "Audio Language & Subtitles",
                onTap: () => AudioSubtitleDialog.show(context),
              ),
              const SizedBox(width: 6),

              // 6. Open File Picker Button
              _IconButtonGlass(
                icon: Icons.folder_open_rounded,
                tooltip: "Open Video File",
                onTap: () => controller.openFile(),
              ),
              const SizedBox(width: 6),

              // 7. Playback Speed Selector Popover
              const SpeedMenu(),
              const SizedBox(width: 6),

              // 8. Fullscreen Toggle (F / F11)
              _IconButtonGlass(
                icon: controller.isFullscreen
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                tooltip: "Fullscreen (F11)",
                onTap: () => controller.toggleFullscreen(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayPauseButton({required this.isPlaying, required this.onTap});

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isHovered
                  ? [AppTheme.electricBlueLight, AppTheme.electricBlue]
                  : [AppTheme.electricBlue, AppTheme.electricBlueDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppTheme.electricBlue.withOpacity(0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppTheme.buttonGlow,
          ),
          child: Center(
            child: Icon(
              widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 22,
            ),
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

  const _IconButtonGlass({
    required this.icon,
    required this.tooltip,
    required this.onTap,
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
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppTheme.electricBlue.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: _isHovered
                  ? Border.all(
                      color: AppTheme.electricBlueLight.withOpacity(0.35),
                      width: 1,
                    )
                  : null,
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 19,
                color: _isHovered
                    ? AppTheme.electricBlue
                    : AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
