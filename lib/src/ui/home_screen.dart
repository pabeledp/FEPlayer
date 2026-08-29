import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_theme.dart';
import '../controllers/library_controller.dart';
import '../controllers/player_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/home_media_grid.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenDownloader;

  const HomeScreen({super.key, required this.onOpenDownloader});

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final player = context.read<FEPlayerController>();

    final logoHeight = _isDesktop ? 68.0 : 52.0;

    return Column(
      children: [
        // 1. Stacked Sticky Brand Header (Fixed at top with frosted glass backdrop)
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Official Prominent FE Player Multimedia Organizer Banner
                    Image.asset(
                      'assets/images/fe_player_banner.png',
                      height: logoHeight,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Row(
                        children: [
                          Image.asset('assets/icons/app_logo.png', height: logoHeight * 0.8),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "FE Player",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                "Multimedia Organizer",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Quick Import Local File Button (High Contrast)
                    GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['mp4', 'mkv', 'avi', 'mov', 'webm', 'mp3', 'wav', 'flac'],
                        );
                        if (result != null && result.files.single.path != null) {
                          final path = result.files.single.path!;
                          final name = result.files.single.name;
                          library.addDownloadedMedia(path, name);
                          player.loadMedia(path, name: name);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.buttonGlow,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.folder_open_rounded, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              "Import Video",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. Scrollable Body Content (Scrolls cleanly underneath sticky header)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Storage & Library Status Banner (High Contrast Card)
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.95),
                  borderColor: const Color(0xFFE2E8F0),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.accentGradient,
                          boxShadow: AppTheme.cyanGlow,
                        ),
                        child: const Center(
                          child: Icon(Icons.storage_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "FE Player Local Storage",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  "${library.formattedUsedStorage} used",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1D4ED8),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (library.libraryUsedBytes / (10 * 1024 * 1024 * 1024)).clamp(0.02, 1.0),
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
                                minHeight: 7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Search Bar + Folder Filter Chips
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.95),
                  borderColor: const Color(0xFFCBD5E1),
                  child: TextField(
                    onChanged: library.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: "Search local videos, movies, and downloads...",
                      hintStyle: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF475569)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Folder Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: library.folders.map((f) {
                      final isSelected = library.selectedFolder == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => library.selectFolder(f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppTheme.accentGradient : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF00F2FE) : const Color(0xFFCBD5E1),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? AppTheme.cyanGlow
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                color: isSelected ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 26),

                // 4. Section Title & Media Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${library.selectedFolder} (${library.mediaItems.length})",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    GestureDetector(
                      onTap: onOpenDownloader,
                      child: const Row(
                        children: [
                          Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                          SizedBox(width: 5),
                          Text(
                            "Download New",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 5. Media Grid
                HomeMediaGrid(items: library.mediaItems),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
