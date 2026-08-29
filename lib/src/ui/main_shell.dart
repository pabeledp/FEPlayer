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

  bool get _isWindowsOrLinux =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    final player = context.watch<FEPlayerController>();
    final downloader = context.watch<DownloaderController>();

    return PopScope(
      canPop: !player.isPlayerActive,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (player.isPlayerActive) {
          player.closePlayer();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Stack(
          children: [
            // Background Gradient Canvas
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF8FAFC),
                    Color(0xFFF1F5F9),
                    Color(0xFFE2E8F0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Main Tab Views
            SafeArea(
              child: Column(
                children: [
                  // Windows & Linux Frameless Title Bar Caption Controls
                  if (_isWindowsOrLinux)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanStart: (_) => windowManager.startDragging(),
                              child: const SizedBox(height: 28),
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

            // Floating Apple Bottom Frosted Navigation Bar (Clean 3 Tabs)
            if (!player.isPlayerActive)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AppleNavBar(
                  selectedIndex: _currentTab,
                  onTabSelected: (index) {
                    setState(() => _currentTab = index);
                  },
                ),
              ),

            // Active Hardware Video Player Cinema Surface
            if (player.isPlayerActive)
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: player.isPlayerActive ? 1.0 : 0.0,
                  child: const PlayerScreen(),
                ),
              ),

            // Top Dynamic Island Capsule Notification
            if (downloader.showToast && downloader.toastMessage != null)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: DynamicIslandToast(
                    message: downloader.toastMessage!,
                    isVisible: downloader.showToast,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
