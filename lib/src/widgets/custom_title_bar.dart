import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../controllers/player_controller.dart';
import 'glass_card.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  bool get _isWindowsOrLinux =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux);

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();

    return GlassCard(
      height: 52,
      borderRadius: BorderRadius.circular(18),
      borderWidth: 1.0,
      borderColor: Colors.white.withOpacity(0.22),
      color: const Color(0xE60F172A), // Dark Frosted Cinema Glass on Video Surface
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // 1. Back to Library Button (Pure White)
          _WindowButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => controller.closePlayer(),
            tooltip: "Back to Library (Esc)",
          ),
          const SizedBox(width: 8),

          // 2. Sidebar / Playlist Toggle Button (Pure White)
          _WindowButton(
            icon: controller.sidebarVisible ? Icons.menu_open_rounded : Icons.menu_rounded,
            onTap: () => controller.toggleSidebar(),
            tooltip: "Toggle Queue (L)",
          ),
          const SizedBox(width: 10),

          // 3. Drag Window Area on Desktop with White Logo & Title
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                if (_isDesktop) {
                  windowManager.startDragging();
                }
              },
              child: Row(
                children: [
                  // Official White Banner Logo on Video Playback Screen
                  Image.asset(
                    'assets/images/fe_player_banner_white.png',
                    height: 42,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/fe_player_banner.png',
                      height: 42,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 1.2,
                    height: 18,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(width: 14),
                  // Current Playing Video Title in Pure White
                  Expanded(
                    child: Text(
                      controller.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Windows & Linux Caption Controls ONLY in White (Hidden on macOS/Mobile)
          if (_isWindowsOrLinux) ...[
            _WindowButton(
              icon: Icons.remove,
              onTap: () => windowManager.minimize(),
              tooltip: "Minimize",
            ),
            const SizedBox(width: 6),
            _WindowButton(
              icon: Icons.crop_square_rounded,
              onTap: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
              tooltip: "Maximize / Restore",
            ),
            const SizedBox(width: 6),
            _WindowButton(
              icon: Icons.close_rounded,
              onTap: () => windowManager.close(),
              isClose: true,
              tooltip: "Close",
            ),
          ],
        ],
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isClose;
  final String tooltip;

  const _WindowButton({
    required this.icon,
    required this.onTap,
    this.isClose = false,
    required this.tooltip,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _isHovered
                  ? (widget.isClose
                      ? Colors.red.withOpacity(0.85)
                      : Colors.white.withOpacity(0.2))
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isHovered
                    ? (widget.isClose
                        ? Colors.red.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5))
                    : Colors.white.withOpacity(0.18),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 17,
                color: Colors.white, // All icons pure crisp white on Video Player
              ),
            ),
          ),
        ),
      ),
    );
  }
}
