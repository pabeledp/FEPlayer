import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import 'glass_card.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();

    return GlassCard(
      height: 48,
      borderRadius: BorderRadius.circular(16),
      borderWidth: 1.0,
      borderColor: Colors.white.withOpacity(0.25),
      color: Colors.white.withOpacity(0.18),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // Back to Library Button
          _WindowButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => controller.closePlayer(),
            tooltip: "Back to Library (Esc)",
          ),
          const SizedBox(width: 8),

          // Sidebar / Playlist toggle button
          _WindowButton(
            icon: controller.sidebarVisible ? Icons.menu_open_rounded : Icons.menu_rounded,
            onTap: () => controller.toggleSidebar(),
            tooltip: "Toggle Queue (L)",
          ),
          const SizedBox(width: 8),

          // Drag Window Area on Desktop
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
                  // Official FE Player Multimedia Organizer Brand Image
                  Image.asset(
                    'assets/images/fe_player_banner.png',
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 1,
                    height: 16,
                    color: AppTheme.glassBorder,
                  ),
                  const SizedBox(width: 12),
                  // Current Video / Media Title
                  Expanded(
                    child: Text(
                      controller.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Window Action Controls
          if (_isDesktop) ...[
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
          ] else ...[
            _WindowButton(
              icon: controller.isFullscreen
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
              onTap: () => controller.toggleFullscreen(),
              tooltip: "Toggle Fullscreen",
            ),
          ]
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isHovered
                  ? (widget.isClose
                      ? Colors.red.withOpacity(0.85)
                      : AppTheme.electricBlue.withOpacity(0.12))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: _isHovered
                  ? Border.all(
                      color: widget.isClose
                          ? Colors.red.withOpacity(0.3)
                          : AppTheme.neonCyan.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: 16,
                color: _isHovered && widget.isClose
                    ? Colors.white
                    : (_isHovered
                        ? AppTheme.electricBlue
                        : AppTheme.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
