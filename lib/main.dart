import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'src/constants/app_theme.dart';
import 'src/controllers/player_controller.dart';
import 'src/controllers/downloader_controller.dart';
import 'src/controllers/library_controller.dart';
import 'src/controllers/fe_audio_handler.dart';
import 'src/ui/main_shell.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MediaKit libmpv hardware engine
  MediaKit.ensureInitialized();

  // Desktop Window Configuration & Acrylic Glass
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await Window.initialize();
    await windowManager.ensureInitialized();

    if (Platform.isWindows) {
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
      size: Size(1180, 750),
      minimumSize: Size(700, 480),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Initialize AudioService for Lockscreen & Notification Center Controls
  FEAudioHandler? audioHandler;
  try {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      audioHandler = await AudioService.init(
        builder: () => FEAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.fe_player.channel.audio',
          androidNotificationChannelName: 'FE Player Playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
    }
  } catch (e) {
    debugPrint("AudioService initialization: $e");
  }

  final libraryController = LibraryController();
  final downloaderController = DownloaderController();
  final playerController = FEPlayerController(audioHandler: audioHandler);

  // Wire download completion into Library
  downloaderController.onDownloadComplete = (filePath, title) {
    libraryController.addDownloadedMedia(filePath, title);
  };

  // If launched via "Open With" with a video file argument
  if (args.isNotEmpty && File(args.first).existsSync()) {
    final file = File(args.first);
    final fileName = file.path.split(Platform.pathSeparator).last;
    playerController.loadMedia(file.path, name: fileName);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: playerController),
        ChangeNotifierProvider.value(value: libraryController),
        ChangeNotifierProvider.value(value: downloaderController),
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
      title: 'FE Player - Multimedia Organizer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}
