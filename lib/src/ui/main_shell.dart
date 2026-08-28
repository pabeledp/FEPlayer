import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../constants/app_theme.dart';
import '../controllers/player_controller.dart';
import '../controllers/downloader_controller.dart';
import '../widgets/apple_nav_bar.dart';
import '../widgets/dynamic_island_toast.dart';
import '../widgets/downloader_modal.dart';
import 'home_screen.dart';
import 'downloader_screen.dart';
import 'settings_screen.dart';
import 'player_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTab = 0;

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    final player = context.watch<FEPlayerController>();
    final downloader = context.watch<DownloaderController>();

    // If player is active, show the futuristic full-screen video player viewport!
    if (player.isPlayerActive) {
      return const PlayerScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Background Gradient Mesh
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.neonCyan.withOpacity(0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonCyan.withOpacity(0.12),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.electricBlue.withOpacity(0.06),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.electricBlue.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // Main Tab Views
          SafeArea(
            child: Column(
              children: [
                // Desktop Frameless Top Bar Window Controls
                if (_isDesktop)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanStart: (_) => windowManager.startDragging(),
                            child: const SizedBox(height: 24),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 16),
                          onPressed: () => windowManager.minimize(),
                          tooltip: "Minimize",
                        ),
                        IconButton(
                          icon: const Icon(Icons.crop_square_rounded, size: 16),
                          onPressed: () async {
                            if (await windowManager.isMaximized()) {
                              windowManager.unmaximize();
                            } else {
                              windowManager.maximize();
                            }
                          },
                          tooltip: "Maximize",
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red),
                          onPressed: () => windowManager.close(),
                          tooltip: "Close",
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: IndexedStack(
                    index: _currentTab,
                    children: [
                      HomeScreen(onOpenDownloader: () {
                        setState(() => _currentTab = 1);
                      }),
                      const DownloaderScreen(),
                      const SettingsScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Apple-Style Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: AppleNavBar(
                  selectedIndex: _currentTab,
                  onTabSelected: (index) {
                    setState(() => _currentTab = index);
                  },
                  onQuickAction: () {
                    DownloaderModal.show(context);
                  },
                ),
              ),
            ),
          ),

          // Dynamic Island Top Capsule Toast
          DynamicIslandToast(
            message: downloader.toastMessage ?? "Saved to FE Player Library",
            isVisible: downloader.showToast,
          ),
        ],
      ),
    );
  }
}
