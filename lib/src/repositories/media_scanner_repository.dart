import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_file.dart';
import '../models/media_folder.dart';

class MediaScannerRepository {
  static const String _cacheKey = "cached_media_files_v1";

  static const List<String> videoExtensions = [
    '.mp4',
    '.mkv',
    '.webm',
    '.avi',
    '.mov',
    '.flv',
    '.ts',
    '.m4v',
  ];

  static const List<String> audioExtensions = [
    '.mp3',
    '.m4a',
    '.wav',
    '.aac',
    '.flac',
    '.ogg',
  ];

  // 1. Load from Shared Preferences Local Cache
  Future<List<LocalMediaFile>> loadCachedMedia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((item) => LocalMediaFile(
          id: item['id'] as String,
          title: item['title'] as String,
          path: item['path'] as String,
          sizeBytes: item['sizeBytes'] as int,
          duration: Duration(seconds: item['durationSec'] as int? ?? 0),
          modifiedDate: DateTime.tryParse(item['modifiedDate'] as String? ?? '') ?? DateTime.now(),
          folder: item['folder'] as String? ?? 'Media',
          isVideo: item['isVideo'] as bool? ?? true,
        )).where((file) {
          if (!kIsWeb) {
            return File(file.path).existsSync();
          }
          return true;
        }).toList();
      }
    } catch (e) {
      debugPrint("Error reading cached media: $e");
    }
    return [];
  }

  // 2. Save into Shared Preferences Local Cache
  Future<void> saveMediaCache(List<LocalMediaFile> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = items.map((f) => {
        'id': f.id,
        'title': f.title,
        'path': f.path,
        'sizeBytes': f.sizeBytes,
        'durationSec': f.duration.inSeconds,
        'modifiedDate': f.modifiedDate.toIso8601String(),
        'folder': f.folder,
        'isVideo': f.isVideo,
      }).toList();
      await prefs.setString(_cacheKey, jsonEncode(data));
    } catch (e) {
      debugPrint("Error saving media cache: $e");
    }
  }

  // 3. Asynchronous Physical Storage Scanning
  Future<List<LocalMediaFile>> scanDeviceStorage() async {
    final scannedItems = <LocalMediaFile>[];
    final targetDirs = <Directory>[];

    if (kIsWeb) return scannedItems;

    try {
      // FE Player Dedicated Documents Media Library
      final docs = await getApplicationDocumentsDirectory();
      final feDir = Directory('${docs.path}/FEPlayer_Media');
      if (!await feDir.exists()) {
        await feDir.create(recursive: true);
      }
      targetDirs.add(feDir);

      if (Platform.isAndroid) {
        final androidPaths = [
          '/storage/emulated/0/DCIM/Camera',
          '/storage/emulated/0/DCIM',
          '/storage/emulated/0/Movies',
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Videos',
          '/storage/emulated/0/Music',
          '/sdcard/DCIM/Camera',
          '/sdcard/Movies',
          '/sdcard/Download',
          '/sdcard/Music',
        ];
        for (final p in androidPaths) {
          final d = Directory(p);
          if (d.existsSync()) {
            targetDirs.add(d);
          }
        }
      } else if (Platform.isMacOS || Platform.isLinux) {
        final home = Platform.environment['HOME'] ?? '';
        if (home.isNotEmpty) {
          final macPaths = [
            '$home/Movies',
            '$home/Downloads',
            '$home/Music',
          ];
          for (final p in macPaths) {
            final d = Directory(p);
            if (d.existsSync()) {
              targetDirs.add(d);
            }
          }
        }
      } else if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'] ?? '';
        if (userProfile.isNotEmpty) {
          final winPaths = [
            '$userProfile\\Videos',
            '$userProfile\\Downloads',
            '$userProfile\\Music',
          ];
          for (final p in winPaths) {
            final d = Directory(p);
            if (d.existsSync()) {
              targetDirs.add(d);
            }
          }
        }
      }

      for (final dir in targetDirs) {
        final folderName = dir.path.split(Platform.pathSeparator).last;
        try {
          final entities = dir.listSync(recursive: false);
          for (final entity in entities) {
            if (entity is File) {
              final pathLower = entity.path.toLowerCase();
              final isVideo = videoExtensions.any((ext) => pathLower.endsWith(ext));
              final isAudio = audioExtensions.any((ext) => pathLower.endsWith(ext));

              if (isVideo || isAudio) {
                final stat = await entity.stat();
                final fileName = entity.path.split(Platform.pathSeparator).last;

                if (!scannedItems.any((m) => m.path == entity.path)) {
                  scannedItems.add(
                    LocalMediaFile(
                      id: entity.path,
                      title: fileName,
                      path: entity.path,
                      sizeBytes: stat.size,
                      duration: const Duration(minutes: 0, seconds: 0),
                      modifiedDate: stat.modified,
                      folder: folderName.isEmpty ? "Media" : folderName,
                      isVideo: isVideo,
                    ),
                  );
                }
              }
            }
          }
        } catch (e) {
          debugPrint("Directory scan error at ${dir.path}: $e");
        }
      }

      // Sort by modified date descending (newest first)
      scannedItems.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));

      // Save to cache
      await saveMediaCache(scannedItems);
    } catch (e) {
      debugPrint("Storage scan failed: $e");
    }

    return scannedItems;
  }

  // 4. Build Folders Map Model
  Map<String, MediaFolderModel> groupMediaByFolders(List<LocalMediaFile> mediaFiles) {
    final map = <String, MediaFolderModel>{};

    for (final file in mediaFiles) {
      final folderKey = file.folder ?? "Media";
      final parentPath = File(file.path).parent.path;

      if (!map.containsKey(folderKey)) {
        map[folderKey] = MediaFolderModel(
          name: folderKey,
          path: parentPath,
          files: [],
        );
      }
      map[folderKey]!.files.add(file);
    }

    return map;
  }
}
