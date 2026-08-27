import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import 'glass_container.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();

    return GlassContainer(
      height: 48,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      borderWidth: 0.8,
      borderColor: AppTheme.glassBorder,
      backgroundColor: AppTheme.glassPanel,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // Sidebar / Library toggle button (VLC feature)
          _WindowButton(
            icon: controller.sidebarVisible ? Icons.menu_open_rounded : Icons.menu_rounded,
            onTap: () => controller.toggleSidebar(),
            tooltip: "Toggle Media Library (L)",
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
                  // App Logo with Electric Blue Glow
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.electricBlue, AppTheme.electricBlueLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: AppTheme.buttonGlow,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // App Brand
                  const Text(
                    "FE PLAYER",
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
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
                        fontWeight: FontWeight.w500,
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
                          : AppTheme.electricBlueLight.withOpacity(0.3),
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
