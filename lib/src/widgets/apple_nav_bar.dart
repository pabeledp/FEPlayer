import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class AppleNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQuickAction;

  const AppleNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 500;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.08),
                  blurRadius: 28,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavTab(
                  icon: Icons.video_library_rounded,
                  label: "Library",
                  isSelected: selectedIndex == 0,
                  onTap: () => onTabSelected(0),
                  isCompact: isCompact,
                ),
                _NavTab(
                  icon: Icons.cloud_download_rounded,
                  label: "Downloader",
                  isSelected: selectedIndex == 1,
                  onTap: () => onTabSelected(1),
                  isCompact: isCompact,
                ),

                // Quick Action Floating Button (Center Highlight)
                GestureDetector(
                  onTap: onQuickAction,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 10 : 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.buttonGlow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_link_rounded, color: Colors.white, size: 18),
                        if (!isCompact) ...[
                          const SizedBox(width: 6),
                          const Text(
                            "Paste URL",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                _NavTab(
                  icon: Icons.tune_rounded,
                  label: "Settings",
                  isSelected: selectedIndex == 2,
                  onTap: () => onTabSelected(2),
                  isCompact: isCompact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(color: const Color(0xFFBFDBFE), width: 1.0)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            ),
            if (isSelected && !isCompact) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
