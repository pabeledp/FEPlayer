import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import 'glass_container.dart';

class SpeedMenu extends StatelessWidget {
  const SpeedMenu({super.key});

  static const List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();

    return PopupMenuButton<double>(
      tooltip: "Playback Speed",
      offset: const Offset(0, -210),
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (speed) {
        controller.setPlaybackRate(speed);
      },
      itemBuilder: (BuildContext context) {
        return speeds.map((speed) {
          final isSelected = controller.playbackSpeed == speed;
          return PopupMenuItem<double>(
            value: speed,
            height: 34,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.electricBlue.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${speed}x",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.electricBlue
                          : AppTheme.textPrimary,
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppTheme.electricBlue,
                    ),
                ],
              ),
            ),
          );
        }).toList();
      },
      child: GlassContainer(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: AppTheme.glassCard,
        borderWidth: 0.8,
        borderColor: AppTheme.glassBorder,
        child: Center(
          child: Text(
            "${controller.playbackSpeed}x",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
