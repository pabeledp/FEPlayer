import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import 'glass_card.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  bool get _isWindowsOrLinux =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux);

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();

    // Determine resolution / format badge
    String formatBadge = "HD";
    final ext = controller.fileName.split('.').last.toUpperCase();
    if (ext.isNotEmpty && ext.length <= 4 && ext != controller.fileName.toUpperCase()) {
      formatBadge = ext;
    }

    return GlassCard(
      height: 52,
      borderRadius: BorderRadius.circular(18),
      borderWidth: 1.0,
      borderColor: Colors.white.withOpacity(0.22),
      color: const Color(0xE60F172A), // Dark Frosted Cinema Glass on Video Surface
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // 1. Back to Library Button (Pure White)
          _WindowButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => controller.closePlayer(),
            tooltip: "Back to Library (Esc)",
          ),
          const SizedBox(width: 12),

          // 2. Drag Window Area on Desktop with White Logo & Title
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                if (_isDesktop) {
                  windowManager.startDragging();
                }
              },
              child: Row(
                children: [
                  // Title & Resolution Tag
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            controller.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: AppTheme.cyanGlow,
                          ),
                          child: Text(
                            formatBadge,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 3. Dynamic Ambient Audio Waveform Visualizer
                  _AudioVisualizerBar(isPlaying: controller.isPlaying),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 4. Loop Playback Toggle Button
          _WindowButton(
            icon: controller.loopMode == PlayerLoopMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            isActive: controller.loopMode != PlayerLoopMode.off,
            onTap: () {
              controller.toggleLoopMode();
              String modeText = "Loop Off";
              if (controller.loopMode == PlayerLoopMode.one) {
                modeText = "Loop Current Track (1)";
              } else if (controller.loopMode == PlayerLoopMode.all) {
                modeText = "Loop All";
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF0F172A),
                  content: Text(
                    "Repeat Mode: $modeText",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              );
            },
            tooltip: "Loop Playback",
          ),
          const SizedBox(width: 6),

          // 5. Sleep Timer Quick Action Button
          _WindowButton(
            icon: Icons.bedtime_rounded,
            isActive: controller.sleepTimerOption != SleepTimerOption.off,
            badge: controller.sleepTimerRemaining != null
                ? "${(controller.sleepTimerRemaining!.inSeconds / 60).ceil()}m"
                : null,
            onTap: () => _showSleepTimerDialog(context, controller),
            tooltip: "Sleep Timer",
          ),

          // 6. Windows & Linux Caption Controls ONLY (Hidden on macOS/Mobile)
          if (_isWindowsOrLinux) ...[
            const SizedBox(width: 8),
            Container(width: 1, height: 16, color: Colors.white.withOpacity(0.25)),
            const SizedBox(width: 8),
            _WindowButton(
              icon: Icons.remove,
              onTap: () => windowManager.minimize(),
              tooltip: "Minimize",
            ),
            const SizedBox(width: 6),
            _WindowButton(
              icon: Icons.crop_square_rounded,
              onTap: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
              tooltip: "Maximize / Restore",
            ),
            const SizedBox(width: 6),
            _WindowButton(
              icon: Icons.close_rounded,
              onTap: () => windowManager.close(),
              isClose: true,
              tooltip: "Close",
            ),
          ],
        ],
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context, FEPlayerController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xF20F172A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bedtime_rounded, color: AppTheme.neonCyan, size: 22),
                          SizedBox(width: 10),
                          Text(
                            "Sleep Timer",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (controller.sleepTimerOption != SleepTimerOption.off)
                        GestureDetector(
                          onTap: () {
                            controller.setSleepTimer(SleepTimerOption.off);
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            "Turn Off",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Automatically pause and shut down playback after:",
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _TimerPill(
                        label: "15 Minutes",
                        isSelected: controller.sleepTimerOption == SleepTimerOption.min15,
                        onTap: () {
                          controller.setSleepTimer(SleepTimerOption.min15);
                          Navigator.pop(ctx);
                        },
                      ),
                      _TimerPill(
                        label: "30 Minutes",
                        isSelected: controller.sleepTimerOption == SleepTimerOption.min30,
                        onTap: () {
                          controller.setSleepTimer(SleepTimerOption.min30);
                          Navigator.pop(ctx);
                        },
                      ),
                      _TimerPill(
                        label: "45 Minutes",
                        isSelected: controller.sleepTimerOption == SleepTimerOption.min45,
                        onTap: () {
                          controller.setSleepTimer(SleepTimerOption.min45);
                          Navigator.pop(ctx);
                        },
                      ),
                      _TimerPill(
                        label: "60 Minutes",
                        isSelected: controller.sleepTimerOption == SleepTimerOption.min60,
                        onTap: () {
                          controller.setSleepTimer(SleepTimerOption.min60);
                          Navigator.pop(ctx);
                        },
                      ),
                      _TimerPill(
                        label: "End of Track",
                        isSelected: controller.sleepTimerOption == SleepTimerOption.endOfTrack,
                        onTap: () {
                          controller.setSleepTimer(SleepTimerOption.endOfTrack);
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AudioVisualizerBar extends StatefulWidget {
  final bool isPlaying;

  const _AudioVisualizerBar({required this.isPlaying});

  @override
  State<_AudioVisualizerBar> createState() => _AudioVisualizerBarState();
}

class _AudioVisualizerBarState extends State<_AudioVisualizerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _AudioVisualizerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_anim.isAnimating) {
      _anim.repeat(reverse: true);
    } else if (!widget.isPlaying && _anim.isAnimating) {
      _anim.stop();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final val = widget.isPlaying ? _anim.value : 0.2;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bar(10 + (val * 12)),
            const SizedBox(width: 3),
            _bar(6 + ((1 - val) * 14)),
            const SizedBox(width: 3),
            _bar(12 + (val * 8)),
            const SizedBox(width: 3),
            _bar(8 + ((1 - val) * 10)),
          ],
        );
      },
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 3,
      height: height.clamp(4.0, 22.0),
      decoration: BoxDecoration(
        color: AppTheme.neonCyan,
        borderRadius: BorderRadius.circular(2),
        boxShadow: AppTheme.cyanGlow,
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimerPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.accentGradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.neonCyan : Colors.white.withOpacity(0.2),
            width: 1.0,
          ),
          boxShadow: isSelected ? AppTheme.buttonGlow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isClose;
  final bool isActive;
  final String? badge;
  final String tooltip;

  const _WindowButton({
    required this.icon,
    required this.onTap,
    this.isClose = false,
    this.isActive = false,
    this.badge,
    required this.tooltip,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? const Color(0xFF00F2FE).withOpacity(0.25)
                  : (_isHovered
                      ? (widget.isClose
                          ? Colors.red.withOpacity(0.85)
                          : Colors.white.withOpacity(0.2))
                      : Colors.white.withOpacity(0.08)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.isActive
                    ? const Color(0xFF00F2FE)
                    : (_isHovered
                        ? (widget.isClose
                            ? Colors.red.withOpacity(0.5)
                            : Colors.white.withOpacity(0.5))
                        : Colors.white.withOpacity(0.18)),
                width: 1.0,
              ),
              boxShadow: widget.isActive ? AppTheme.cyanGlow : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 17,
                  color: widget.isActive
                      ? const Color(0xFF00F2FE)
                      : Colors.white,
                ),
                if (widget.badge != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    widget.badge!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.neonCyan,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
