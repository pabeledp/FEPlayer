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

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final player = context.read<FEPlayerController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Official FE Player Multimedia Organizer Banner & Quick Import
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/fe_player_banner.png',
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Row(
                  children: [
                    Image.asset('assets/icons/app_logo.png', height: 40),
                    const SizedBox(width: 12),
                    const Text(
                      "FE Player",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Quick Import Local File Button
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.18),
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open_rounded, size: 16, color: AppTheme.electricBlue),
                    SizedBox(width: 6),
                    Text(
                      "Import File",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Storage & Library Status Banner
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
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
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            "${library.formattedUsedStorage} used",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.electricBlue,
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
                          backgroundColor: Colors.black.withOpacity(0.08),
                          valueColor: const AlwaysStoppedAnimation(AppTheme.electricBlue),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Search Bar + Folder Filter Chips
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.12),
                  child: TextField(
                    onChanged: library.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: "Search local videos and downloads...",
                      hintStyle: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      prefixIcon: Icon(Icons.search_rounded, size: 18, color: AppTheme.textSecondary),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  ),
                ),
              ),
            ],
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.accentGradient : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.neonCyan : Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: isSelected ? AppTheme.cyanGlow : null,
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 28),

          // 4. Section Title & Media Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${library.selectedFolder} (${library.mediaItems.length})",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: onOpenDownloader,
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 16, color: AppTheme.electricBlue),
                    SizedBox(width: 4),
                    Text(
                      "Download New",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.electricBlue,
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
    );
  }
}
