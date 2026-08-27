import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'src/constants/app_theme.dart';
import 'src/controllers/player_controller.dart';
import 'src/ui/player_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MediaKit libmpv hardware engine
  MediaKit.ensureInitialized();

  // Desktop Window Configuration & Acrylic Glass
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await Window.initialize();
    await windowManager.ensureInitialized();

    if (Platform.isWindows) {
      // Enable Acrylic / Mica frosted glass effect for Windows
      await Window.setEffect(
        effect: WindowEffect.acrylic,
        color: const Color(0x33F8FAFC),
        dark: false,
      );
    } else if (Platform.isMacOS) {
      await Window.setEffect(
        effect: WindowEffect.hudWindow,
        dark: false,
      );
    }

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1100, 680),
      minimumSize: Size(640, 400),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden, // Frameless custom titlebar
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FEPlayerController()),
      ],
      child: const FEPlayerApp(),
    ),
  );
}

class FEPlayerApp extends StatelessWidget {
  const FEPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FE Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PlayerScreen(),
    );
  }
}
