import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class AppleNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const AppleNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22.0, sigmaY: 22.0),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(30),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavIconTab(
                    icon: Icons.video_library_rounded,
                    tooltip: "Media Library",
                    isSelected: selectedIndex == 0,
                    onTap: () => onTabSelected(0),
                  ),
                  _NavIconTab(
                    icon: Icons.cloud_download_rounded,
                    tooltip: "FE Downloader",
                    isSelected: selectedIndex == 1,
                    onTap: () => onTabSelected(1),
                  ),
                  _NavIconTab(
                    icon: Icons.tune_rounded,
                    tooltip: "Settings & Preferences",
                    isSelected: selectedIndex == 2,
                    onTap: () => onTabSelected(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconTab extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavIconTab({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavIconTab> createState() => _NavIconTabState();
}

class _NavIconTabState extends State<_NavIconTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 58,
            height: 42,
            decoration: BoxDecoration(
              gradient: widget.isSelected ? AppTheme.accentGradient : null,
              color: widget.isSelected
                  ? null
                  : (_isHovered
                      ? const Color(0xFFF1F5F9)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(22),
              border: widget.isSelected
                  ? Border.all(color: const Color(0xFF00F2FE), width: 1.2)
                  : null,
              boxShadow: widget.isSelected ? AppTheme.buttonGlow : null,
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 22,
                color: widget.isSelected
                    ? Colors.white
                    : (_isHovered
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
