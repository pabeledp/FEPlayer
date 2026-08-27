import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/player_controller.dart';
import '../widgets/custom_title_bar.dart';
import '../widgets/video_viewport.dart';
import '../widgets/glass_controls_bar.dart';
import '../widgets/glass_sidebar.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FEPlayerController>();

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        controller.handleKeyEvent(event);
      },
      child: MouseRegion(
        onHover: (_) => controller.onUserInteraction(),
        onExit: (_) => controller.onMouseExitScreen(),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 1. Full Screen Video Surface
              const Positioned.fill(
                child: VideoViewport(),
              ),

              // 2. Custom Frameless Title Bar (Top)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                top: controller.controlsVisible ? 0 : -65,
                left: 0,
                right: 0,
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: CustomTitleBar(),
                  ),
                ),
              ),

              // 3. Floating Bottom Glass Control Bar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                bottom: controller.controlsVisible ? 24 : -130,
                left: 24,
                right: 24,
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: const GlassControlsBar(),
                    ),
                  ),
                ),
              ),

              // 4. VLC-Inspired Futuristic Glass Sidebar (Drawer / Library)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                top: 56,
                bottom: 24,
                left: controller.sidebarVisible ? 16 : -320,
                child: const GlassSidebar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
