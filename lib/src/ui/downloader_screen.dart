import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/downloader_controller.dart';
import '../models/download_item.dart';
import '../widgets/glass_card.dart';
import '../widgets/quality_chip.dart';
import '../widgets/download_progress_card.dart';

class DownloaderScreen extends StatefulWidget {
  const DownloaderScreen({super.key});

  @override
  State<DownloaderScreen> createState() => _DownloaderScreenState();
}

class _DownloaderScreenState extends State<DownloaderScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _detectedPlatform = "";

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    final downloader = context.read<DownloaderController>();
    final platform = downloader.detectPlatform(_urlController.text);
    if (platform != _detectedPlatform) {
      setState(() {
        _detectedPlatform = platform;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      _urlController.text = data.text!;
      if (mounted) {
        context.read<DownloaderController>().fetchMetadata(data.text!);
      }
    }
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloader = context.watch<DownloaderController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section with Gradient Title & Network / Storage Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => AppTheme.accentGradient.createShader(bounds),
                    child: const Text(
                      "FE Downloader",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Ultra-Fast Glassmorphic Stream & Video Extractor",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              // Network & Storage Status Badge
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.15),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wifi_rounded, size: 14, color: AppTheme.neonCyan),
                    SizedBox(width: 6),
                    Text(
                      "High-Speed • Ready",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Smart Input Field (Frosted Glass + Inline Paste + Dynamic Platform Glow)
          GlassCard(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withOpacity(0.15),
            borderColor: _detectedPlatform.isNotEmpty
                ? AppTheme.neonCyan.withOpacity(0.4)
                : Colors.white.withOpacity(0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Dynamic Platform Icon Glow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _detectedPlatform.isNotEmpty ? AppTheme.accentGradient : null,
                        color: _detectedPlatform.isEmpty ? Colors.black.withOpacity(0.06) : null,
                        boxShadow: _detectedPlatform.isNotEmpty ? AppTheme.cyanGlow : null,
                      ),
                      child: Icon(
                        _detectedPlatform == 'YouTube'
                            ? Icons.play_circle_filled_rounded
                            : Icons.link_rounded,
                        color: _detectedPlatform.isNotEmpty ? Colors.white : AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        onSubmitted: (url) => downloader.fetchMetadata(url),
                        decoration: InputDecoration(
                          hintText: "Paste YouTube, Vimeo or direct video link...",
                          hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                          isDense: true,
                          suffixIcon: _urlController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  onPressed: () {
                                    _urlController.clear();
                                  },
                                )
                              : null,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Inline Paste Button
                    GestureDetector(
                      onTap: _pasteFromClipboard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.content_paste_rounded, size: 14, color: AppTheme.electricBlue),
                            SizedBox(width: 4),
                            Text(
                              "Paste",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Fetch Metadata Button
                    GestureDetector(
                      onTap: downloader.isFetching
                          ? null
                          : () => downloader.fetchMetadata(_urlController.text),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.buttonGlow,
                        ),
                        child: downloader.isFetching
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    "Fetch",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),

                if (_detectedPlatform.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.neonCyan.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Detected: $_detectedPlatform",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.vibrantBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Media Preview & Adaptive Quality Selector (Post-Fetch)
          if (downloader.currentMetadata != null) ...[
            _buildMetadataPreviewCard(context, downloader, downloader.currentMetadata!),
            const SizedBox(height: 24),
          ],

          // 4. Active Downloads Section
          if (downloader.activeDownloads.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.downloading_rounded, size: 18, color: AppTheme.electricBlue),
                SizedBox(width: 8),
                Text(
                  "Active Downloads",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...downloader.activeDownloads.map((item) => DownloadProgressCard(item: item)),
            const SizedBox(height: 20),
          ],

          // 5. Completed Downloads Section
          if (downloader.completedDownloads.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Completed Downloads",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...downloader.completedDownloads.map((item) => DownloadProgressCard(item: item)),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataPreviewCard(
      BuildContext context, DownloaderController downloader, DownloadMetadata meta) {
    final isAudio = downloader.selectedFormat == DownloadFormat.audioMp3;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      color: Colors.white.withOpacity(0.18),
      borderColor: AppTheme.neonCyan.withOpacity(0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Split Preview (Thumbnail + Details)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Container(
                      width: 140,
                      height: 90,
                      color: Colors.black26,
                      child: Image.network(
                        meta.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.movie_creation_outlined, color: AppTheme.electricBlue),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          meta.formattedDuration,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Title & Author
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.account_circle_rounded, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          meta.author,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Row 2: Format Switcher (Glass Segmented Control)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SegmentTab(
                    icon: Icons.videocam_rounded,
                    label: "Video (MP4)",
                    isSelected: !isAudio,
                    onTap: () => downloader.setFormat(DownloadFormat.videoMp4),
                  ),
                ),
                Expanded(
                  child: _SegmentTab(
                    icon: Icons.headphones_rounded,
                    label: "Audio Only (MP3)",
                    isSelected: isAudio,
                    onTap: () => downloader.setFormat(DownloadFormat.audioMp3),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Row 3: Resolution / Quality Chips
          if (!isAudio) ...[
            const Text(
              "Select Resolution & Quality:",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: meta.availableResolutions.map((res) {
                final isSelected = downloader.selectedResolution == res;
                return QualityChip(
                  resolution: res,
                  isSelected: isSelected,
                  onTap: () => downloader.setResolution(res),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Row 4: Primary Download CTA Button
          GestureDetector(
            onTap: () => downloader.startDownload(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cyanGlow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isAudio ? "Download High-Quality MP3" : "Download ${downloader.selectedResolution?.label ?? 'Video'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.electricBlue : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
