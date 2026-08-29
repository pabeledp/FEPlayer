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
    final url = _urlController.text.trim();
    final downloader = context.read<DownloaderController>();
    final platform = downloader.detectPlatform(url);
    if (platform != _detectedPlatform) {
      setState(() {
        _detectedPlatform = platform;
      });
    }

    // Smart Auto-Fetch when valid YouTube or media link is pasted
    if ((url.contains("youtube.com/") || url.contains("youtu.be/")) && url.length >= 18) {
      downloader.fetchMetadata(url);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      final text = data.text!.trim();
      _urlController.text = text;
      if (mounted) {
        context.read<DownloaderController>().fetchMetadata(text);
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
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
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
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Paste link to extract 4K/1080p video or high-quality audio",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Input Bar with Instant Paste Link Button
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.95),
                borderColor: _detectedPlatform.isNotEmpty
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
                child: Row(
                  children: [
                    // Platform Icon
                    Icon(
                      _detectedPlatform == 'YouTube'
                          ? Icons.play_circle_filled_rounded
                          : Icons.link_rounded,
                      color: _detectedPlatform.isNotEmpty
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                      size: 24,
                    ),
                    const SizedBox(width: 10),

                    // URL Input Field
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        onSubmitted: (url) => downloader.fetchMetadata(url),
                        decoration: InputDecoration(
                          hintText: "Paste YouTube or video stream link...",
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          isDense: true,
                          suffixIcon: _urlController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF64748B)),
                                  onPressed: () => _urlController.clear(),
                                )
                              : null,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Instant Paste Button
                    GestureDetector(
                      onTap: _pasteFromClipboard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.content_paste_rounded, size: 14, color: Color(0xFF2563EB)),
                            SizedBox(width: 6),
                            Text(
                              "Paste Link",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Shimmer Skeleton Loading State during Fetch
              if (downloader.isFetching) ...[
                const SizedBox(height: 20),
                _buildShimmerSkeleton(),
              ],

              // Error Banner if fetch fails
              if (downloader.fetchError != null && !downloader.isFetching) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          downloader.fetchError!,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // 4. Compact Media Card & Format / Resolution Selector
              if (downloader.currentMetadata != null && !downloader.isFetching) ...[
                _buildCompactMediaCard(context, downloader, downloader.currentMetadata!),
                const SizedBox(height: 24),
              ],

              // 5. Active Downloads Section
              if (downloader.activeDownloads.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(Icons.downloading_rounded, size: 18, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Text(
                      "Active Downloads",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...downloader.activeDownloads.map((item) => DownloadProgressCard(item: item)),
                const SizedBox(height: 20),
              ],

              // 6. Completed Downloads Section
              if (downloader.completedDownloads.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      "Completed Downloads",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...downloader.completedDownloads.map((item) => DownloadProgressCard(item: item)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerSkeleton() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withOpacity(0.92),
      borderColor: const Color(0xFFE2E8F0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 110,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 14, color: const Color(0xFFE2E8F0)),
                    const SizedBox(height: 8),
                    Container(width: 120, height: 12, color: const Color(0xFFE2E8F0)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Color(0xFF2563EB))),
              ),
              SizedBox(width: 8),
              Text(
                "Extracting video streams & quality options...",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMediaCard(
      BuildContext context, DownloaderController downloader, DownloadMetadata meta) {
    final isAudio = downloader.selectedFormat == DownloadFormat.audioMp3;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(22),
      color: Colors.white.withOpacity(0.95),
      borderColor: const Color(0xFFBFDBFE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Compact Thumbnail + Title & Duration
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 76,
                      color: const Color(0xFF0F172A),
                      child: Image.network(
                        meta.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.movie_creation_outlined, color: AppTheme.neonCyan),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          meta.formattedDuration,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meta.author,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 2: Format Switcher (Segmented Glass Toggle)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1)),
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

          const SizedBox(height: 16),

          // Row 3: Resolution / Quality Chips
          if (!isAudio) ...[
            const Text(
              "Select Resolution:",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 18),
          ],

          // Row 4: Large Vibrant "Download Now" CTA Button
          GestureDetector(
            onTap: () => downloader.startDownload(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF00D2FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.buttonGlow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isAudio ? "Download Now (MP3 Audio)" : "Download Now (${downloader.selectedResolution?.label ?? 'Video'})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
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
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
