import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import 'glass_container.dart';

class AudioSubtitleDialog extends StatelessWidget {
  const AudioSubtitleDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => const AudioSubtitleDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();
    final audioTracks = controller.tracks.audio;
    final subtitleTracks = controller.tracks.subtitle;

    return Center(
      child: GlassContainer(
        width: 480,
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(20),
        backgroundColor: AppTheme.glassWhite,
        borderColor: AppTheme.glassBorder,
        borderWidth: 1.2,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune_rounded, color: AppTheme.electricBlue, size: 22),
                      SizedBox(width: 10),
                      Text(
                        "Audio & Subtitle Settings",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0x33E2E8F0)),
              const SizedBox(height: 16),

              // 1. Audio Track / Dual Language Selector
              const Text(
                "AUDIO LANGUAGE / TRACK",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.electricBlue,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              if (audioTracks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    "Auto (Default Audio Stream)",
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                )
              else
                ...audioTracks.map((track) {
                  final isSelected = track.id == controller.selectedAudioTrack.id;
                  final title = track.title ?? track.language ?? "Track #${track.id}";
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      controller.setAudioTrack(track);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.electricBlue.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.electricBlueLight.withOpacity(0.4)
                              : const Color(0x22E2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.audiotrack_rounded,
                            size: 16,
                            color: isSelected ? AppTheme.electricBlue : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppTheme.electricBlue : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.electricBlue),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 16),

              // 2. Subtitles Track Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SUBTITLES",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.electricBlue,
                      letterSpacing: 1.1,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => controller.loadExternalSubtitle(),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text("Load .srt", style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.electricBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Option to disable subtitles
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  controller.setSubtitleTrack(SubtitleTrack.no());
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.selectedSubtitleTrack.id == SubtitleTrack.no().id
                        ? AppTheme.electricBlue.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller.selectedSubtitleTrack.id == SubtitleTrack.no().id
                          ? AppTheme.electricBlueLight.withOpacity(0.4)
                          : const Color(0x22E2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.subtitles_off_rounded, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Disable Subtitles",
                          style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                        ),
                      ),
                      if (controller.selectedSubtitleTrack.id == SubtitleTrack.no().id)
                        const Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.electricBlue),
                    ],
                  ),
                ),
              ),

              if (subtitleTracks.isNotEmpty)
                ...subtitleTracks.map((track) {
                  final isSelected = track.id == controller.selectedSubtitleTrack.id;
                  final title = track.title ?? track.language ?? "Subtitle #${track.id}";
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      controller.setSubtitleTrack(track);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.electricBlue.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.electricBlueLight.withOpacity(0.4)
                              : const Color(0x22E2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.subtitles_rounded,
                            size: 16,
                            color: isSelected ? AppTheme.electricBlue : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppTheme.electricBlue : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.electricBlue),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
