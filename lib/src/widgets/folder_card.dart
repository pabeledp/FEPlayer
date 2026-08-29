import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/media_folder.dart';
import '../controllers/library_controller.dart';
import 'glass_card.dart';

class FolderCard extends StatelessWidget {
  final MediaFolderModel folder;

  const FolderCard({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryController>();

    Color typeColor;
    switch (folder.contentType) {
      case FolderContentType.videoOnly:
        typeColor = const Color(0xFF2563EB); // Electric Blue
        break;
      case FolderContentType.audioOnly:
        typeColor = const Color(0xFF8B5CF6); // Purple
        break;
      case FolderContentType.mixed:
        typeColor = const Color(0xFF059669); // Emerald
        break;
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withOpacity(0.95),
      borderColor: const Color(0xFFE2E8F0),
      onTap: () {
        library.openFolder(folder);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Folder Icon with Glow + Content Type Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      typeColor.withOpacity(0.85),
                      typeColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    folder.contentType == FolderContentType.audioOnly
                        ? Icons.library_music_rounded
                        : Icons.folder_special_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),

              // Content Type Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: typeColor.withOpacity(0.25), width: 1.0),
                ),
                child: Text(
                  folder.typeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: typeColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Middle: Folder Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                folder.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              // Bottom: Item count & Disk usage badge
              Row(
                children: [
                  const Icon(Icons.data_usage_rounded, size: 12, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      folder.summaryBadge,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
