import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import 'glass_container.dart';

class GlassSidebar extends StatelessWidget {
  const GlassSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();

    return GlassContainer(
      width: 280,
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
      backgroundColor: AppTheme.glassWhite,
      borderColor: AppTheme.glassBorder,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Title & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.video_library_rounded, color: AppTheme.electricBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "MEDIA HUB",
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 22, color: AppTheme.textSecondary),
                onPressed: () => controller.toggleSidebar(),
                splashRadius: 18,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0x33E2E8F0)),
          const SizedBox(height: 16),

          // 1. SECTION: LIBRARY (VLC style)
          const _SidebarSectionHeader(title: "LIBRARY"),
          _SidebarTile(
            icon: Icons.queue_music_rounded,
            title: "Playlist",
            badgeCount: controller.playlist.length,
            isSelected: true,
            onTap: () {},
          ),
          _SidebarTile(
            icon: Icons.history_rounded,
            title: "Recent Media",
            badgeCount: 3,
            isSelected: false,
            onTap: () {},
          ),

          const SizedBox(height: 16),

          // 2. SECTION: MY COMPUTER
          const _SidebarSectionHeader(title: "MY COMPUTER"),
          _SidebarTile(
            icon: Icons.movie_outlined,
            title: "Open Local File",
            isSelected: false,
            onTap: () => controller.openFile(),
          ),
          _SidebarTile(
            icon: Icons.folder_open_rounded,
            title: "Movies Directory",
            isSelected: false,
            onTap: () => controller.openFile(),
          ),

          const SizedBox(height: 16),

          // 3. SECTION: PLAYLIST ITEMS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SidebarSectionHeader(title: "CURRENT QUEUE"),
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 18, color: AppTheme.electricBlue),
                onPressed: () => controller.openFile(),
                tooltip: "Add File",
                splashRadius: 16,
              ),
            ],
          ),
          const SizedBox(height: 6),

          Expanded(
            child: ListView.builder(
              itemCount: controller.playlist.length,
              itemBuilder: (context, index) {
                final item = controller.playlist[index];
                final isCurrent = controller.currentPlaylistIndex == index;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppTheme.electricBlue.withOpacity(0.12)
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent
                          ? AppTheme.electricBlueLight.withOpacity(0.4)
                          : const Color(0x22E2E8F0),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    dense: true,
                    leading: Icon(
                      isCurrent && controller.isPlaying
                          ? Icons.play_arrow_rounded
                          : Icons.movie_creation_outlined,
                      color: isCurrent ? AppTheme.electricBlue : AppTheme.textSecondary,
                      size: 18,
                    ),
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent ? AppTheme.electricBlue : AppTheme.textPrimary,
                      ),
                    ),
                    trailing: isCurrent
                        ? Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.electricBlue,
                            ),
                          )
                        : null,
                    onTap: () {
                      controller.playPlaylistItem(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSectionHeader extends StatelessWidget {
  final String title;
  const _SidebarSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? badgeCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.title,
    this.badgeCount,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.electricBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppTheme.electricBlue : AppTheme.textPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppTheme.electricBlue : AppTheme.textPrimary,
                ),
              ),
            ),
            if (badgeCount != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.electricBlue : const Color(0x3394A3B8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$badgeCount",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
