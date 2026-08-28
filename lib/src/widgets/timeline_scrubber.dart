import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import 'glass_container.dart';

class TimelineScrubber extends StatefulWidget {
  const TimelineScrubber({super.key});

  @override
  State<TimelineScrubber> createState() => _TimelineScrubberState();
}

class _TimelineScrubberState extends State<TimelineScrubber> {
  bool _isHovering = false;
  double _hoverFraction = 0.0;
  double _hoverGlobalX = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();
    final totalDurationMs = controller.duration.inMilliseconds.toDouble();
    final currentPositionMs = controller.position.inMilliseconds.toDouble();
    final bufferMs = controller.buffer.inMilliseconds.toDouble();

    final progressFraction = totalDurationMs > 0
        ? (currentPositionMs / totalDurationMs).clamp(0.0, 1.0)
        : 0.0;

    final bufferFraction = totalDurationMs > 0
        ? (bufferMs / totalDurationMs).clamp(0.0, 1.0)
        : 0.0;

    final hoverDuration = Duration(
      milliseconds: (_hoverFraction * totalDurationMs).toInt(),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (e) {
            setState(() {
              _isHovering = true;
              _hoverFraction = (e.localPosition.dx / barWidth).clamp(0.0, 1.0);
              _hoverGlobalX = e.localPosition.dx;
            });
          },
          onHover: (e) {
            setState(() {
              _hoverFraction = (e.localPosition.dx / barWidth).clamp(0.0, 1.0);
              _hoverGlobalX = e.localPosition.dx;
            });
          },
          onExit: (_) {
            setState(() {
              _isHovering = false;
            });
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) {
              _isDragging = true;
              final fraction = (details.localPosition.dx / barWidth).clamp(0.0, 1.0);
              controller.seek(
                Duration(milliseconds: (fraction * totalDurationMs).toInt()),
              );
            },
            onHorizontalDragUpdate: (details) {
              final fraction = (details.localPosition.dx / barWidth).clamp(0.0, 1.0);
              controller.seek(
                Duration(milliseconds: (fraction * totalDurationMs).toInt()),
              );
            },
            onHorizontalDragEnd: (_) => _isDragging = false,
            onTapDown: (details) {
              final fraction = (details.localPosition.dx / barWidth).clamp(0.0, 1.0);
              controller.seek(
                Duration(milliseconds: (fraction * totalDurationMs).toInt()),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                // Track Container
                Container(
                  height: _isHovering || _isDragging ? 8 : 5,
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: const Color(0x33CBD5E1), // Light grey track background
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Stack(
                    children: [
                      // Buffer Bar Indicator
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: bufferFraction,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0x6694A3B8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      // Progress Bar with Electric Blue Glow
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progressFraction,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.electricBlue, AppTheme.electricBlueLight],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.electricBlueLight.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Thumb / Handle
                Positioned(
                  left: (progressFraction * barWidth) - (_isHovering ? 7 : 5),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: _isHovering || _isDragging ? 14 : 10,
                    height: _isHovering || _isDragging ? 14 : 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.electricBlue,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.electricBlue.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Glass Hover Tooltip
                if (_isHovering && totalDurationMs > 0)
                  Positioned(
                    left: (_hoverGlobalX - 35).clamp(0.0, barWidth - 70),
                    bottom: 18,
                    child: GlassContainer(
                      height: 26,
                      width: 70,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: AppTheme.glassCard,
                      borderWidth: 1,
                      borderColor: AppTheme.electricBlueLight.withOpacity(0.4),
                      child: Center(
                        child: Text(
                          controller.formatDuration(hoverDuration),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
