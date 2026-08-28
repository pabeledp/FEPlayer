import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/download_item.dart';
import '../controllers/downloader_controller.dart';
import '../controllers/player_controller.dart';
import 'glass_card.dart';

class DownloadProgressCard extends StatelessWidget {
  final ActiveDownload item;

  const DownloadProgressCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final downloader = context.watch<DownloaderController>();
    final player = context.read<FEPlayerController>();
    final isCompleted = item.status == DownloadStatus.completed;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      color: Colors.white.withOpacity(0.14),
      borderColor: isCompleted
          ? AppTheme.neonCyan.withOpacity(0.4)
          : Colors.white.withOpacity(0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Thumbnail + Title + Channel + Quality Badge
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 64,
                  height: 48,
                  color: Colors.black26,
                  child: Image.network(
                    item.metadata.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.video_library_rounded, color: AppTheme.electricBlue, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.metadata.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          item.metadata.author,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: isCompleted ? AppTheme.accentGradient : null,
                            color: isCompleted ? null : AppTheme.electricBlue.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.resolution.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isCompleted ? Colors.white : AppTheme.electricBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Controls (Pause/Resume/Cancel or Play)
              if (isCompleted)
                IconButton(
                  onPressed: () {
                    if (item.savePath != null) {
                      player.loadMedia(item.savePath!, name: item.metadata.title);
                    }
                  },
                  tooltip: "Play Video",
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.accentGradient,
                      boxShadow: AppTheme.buttonGlow,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pause / Resume
                    _GlassCircularButton(
                      icon: item.status == DownloadStatus.paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      tooltip: item.status == DownloadStatus.paused ? "Resume" : "Pause",
                      onTap: () {
                        if (item.status == DownloadStatus.paused) {
                          downloader.resumeDownload(item);
                        } else {
                          downloader.pauseDownload(item);
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    // Cancel
                    _GlassCircularButton(
                      icon: Icons.close_rounded,
                      tooltip: "Cancel",
                      isDestructive: true,
                      onTap: () => downloader.cancelDownload(item),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: Liquid Translucent Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 7,
              width: double.infinity,
              color: Colors.black.withOpacity(0.08),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: item.progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonCyan.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Row 3: Real-Time Metrics (Percentage, Speed, Size, ETA)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCompleted ? "Completed" : "${item.formattedProgress} • ${item.formattedDownloaded}",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  fontFamily: 'monospace',
                ),
              ),
              if (!isCompleted)
                Text(
                  "${item.formattedSpeed} • ETA: ${item.eta}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassCircularButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDestructive;

  const _GlassCircularButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDestructive
                ? Colors.red.withOpacity(0.12)
                : Colors.white.withOpacity(0.18),
            border: Border.all(
              color: isDestructive
                  ? Colors.red.withOpacity(0.3)
                  : Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: isDestructive ? Colors.red : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
