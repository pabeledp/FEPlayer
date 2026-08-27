import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';

class VolumeControl extends StatefulWidget {
  const VolumeControl({super.key});

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();
    final volume = controller.isMuted ? 0.0 : controller.volume;

    IconData volumeIcon;
    if (volume == 0) {
      volumeIcon = Icons.volume_off_rounded;
    } else if (volume < 0.5) {
      volumeIcon = Icons.volume_down_rounded;
    } else {
      volumeIcon = Icons.volume_up_rounded;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(volumeIcon, color: AppTheme.textPrimary, size: 20),
            onPressed: () => controller.toggleMute(),
            splashRadius: 18,
            tooltip: controller.isMuted ? "Unmute (M)" : "Mute (M)",
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: _isHovered ? 80 : 0,
            child: _isHovered
                ? SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      activeTrackColor: AppTheme.electricBlue,
                      inactiveTrackColor: const Color(0x33CBD5E1),
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    ),
                    child: Slider(
                      value: volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (val) {
                        controller.setVolume(val);
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
