import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/media_file.dart';

class LibraryController extends ChangeNotifier {
  final List<LocalMediaFile> _mediaItems = [];
  List<LocalMediaFile> get mediaItems {
    var items = _mediaItems;
    if (_selectedFolder != "All Media") {
      items = items.where((m) => m.folder == _selectedFolder).toList();
    }
    if (_searchQuery.isNotEmpty) {
      items = items.where((m) => m.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return items;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _permissionGranted = false;
  bool get permissionGranted => _permissionGranted;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  final int _totalStorageBytes = 128 * 1024 * 1024 * 1024;
  int get totalStorageBytes => _totalStorageBytes;

  int get libraryUsedBytes => _mediaItems.fold(0, (sum, item) => sum + item.sizeBytes);

  double get storageUsageFraction => _totalStorageBytes > 0
      ? (libraryUsedBytes / _totalStorageBytes).clamp(0.0, 1.0)
      : 0.0;

  List<String> _folders = ["All Media"];
  List<String> get folders => _folders;

  String _selectedFolder = "All Media";
  String get selectedFolder => _selectedFolder;

  LibraryController() {
    initAndScan();
  }

  Future<void> initAndScan() async {
    _isLoading = true;
    notifyListeners();

    await requestStoragePermission();
    await scanDeviceVideos();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> requestStoragePermission() async {
    if (kIsWeb) {
      _permissionGranted = true;
      return true;
    }

    if (Platform.isAndroid) {
      // Android 13+ requires videos/audio permission, older needs storage
      final videoStatus = await Permission.videos.request();
      final audioStatus = await Permission.audio.request();
      final storageStatus = await Permission.storage.request();

      _permissionGranted = videoStatus.isGranted || storageStatus.isGranted || audioStatus.isGranted;
    } else if (Platform.isIOS) {
      final photos = await Permission.photos.request();
      _permissionGranted = photos.isGranted;
    } else {
      // macOS, Windows, Linux
      _permissionGranted = true;
    }

    notifyListeners();
    return _permissionGranted;
  }

  Future<void> scanDeviceVideos() async {
    _mediaItems.clear();
    final folderSet = <String>{"All Media"};

    final targetDirs = <Directory>[];

    try {
      if (!kIsWeb) {
        // 1. FE Player dedicated library folder
        final docs = await getApplicationDocumentsDirectory();
        final feDir = Directory('${docs.path}/FEPlayer_Media');
        if (!await feDir.exists()) {
          await feDir.create(recursive: true);
        }
        targetDirs.add(feDir);

        if (Platform.isAndroid) {
          // Android standard media paths
          final publicPaths = [
            '/storage/emulated/0/DCIM/Camera',
            '/storage/emulated/0/Movies',
            '/storage/emulated/0/Download',
            '/storage/emulated/0/Videos',
            '/sdcard/DCIM/Camera',
            '/sdcard/Movies',
            '/sdcard/Download',
          ];
          for (final p in publicPaths) {
            final dir = Directory(p);
            if (dir.existsSync()) {
              targetDirs.add(dir);
            }
          }
        } else if (Platform.isMacOS) {
          // macOS standard directories
          final home = Platform.environment['HOME'] ?? '';
          if (home.isNotEmpty) {
            final macPaths = [
              '$home/Movies',
              '$home/Downloads',
            ];
            for (final p in macPaths) {
              final dir = Directory(p);
              if (dir.existsSync()) {
                targetDirs.add(dir);
              }
            }
          }
        }

        // Scan directories for media files
        for (final dir in targetDirs) {
          final folderName = dir.path.split('/').last.split('\\').last;
          try {
            final files = dir.listSync(recursive: false);
            for (final entity in files) {
              if (entity is File) {
                final path = entity.path.toLowerCase();
                if (path.endsWith('.mp4') ||
                    path.endsWith('.mkv') ||
                    path.endsWith('.mov') ||
                    path.endsWith('.avi') ||
                    path.endsWith('.webm') ||
                    path.endsWith('.flv') ||
                    path.endsWith('.ts') ||
                    path.endsWith('.m4v') ||
                    path.endsWith('.mp3') ||
                    path.endsWith('.wav') ||
                    path.endsWith('.aac')) {
                  final stat = await entity.stat();
                  final fileName = entity.path.split('/').last.split('\\').last;

                  if (!_mediaItems.any((m) => m.path == entity.path)) {
                    folderSet.add(folderName.isEmpty ? "Media" : folderName);
                    _mediaItems.add(
                      LocalMediaFile(
                        id: entity.path,
                        title: fileName,
                        path: entity.path,
                        sizeBytes: stat.size,
                        duration: const Duration(minutes: 0, seconds: 0),
                        modifiedDate: stat.modified,
                        folder: folderName.isEmpty ? "Media" : folderName,
                        isVideo: !path.endsWith('.mp3') && !path.endsWith('.wav') && !path.endsWith('.aac'),
                      ),
                    );
                  }
                }
              }
            }
          } catch (e) {
            debugPrint("Directory scan error in ${dir.path}: $e");
          }
        }
      }
    } catch (e) {
      debugPrint("Media scanning error: $e");
    }

    _folders = folderSet.toList();
    notifyListeners();
  }

  void addDownloadedMedia(String filePath, String title) {
    final file = File(filePath);
    int size = 10 * 1024 * 1024;
    DateTime mod = DateTime.now();
    if (file.existsSync()) {
      try {
        final stat = file.statSync();
        size = stat.size;
        mod = stat.modified;
      } catch (_) {}
    }

    if (!_mediaItems.any((m) => m.path == filePath)) {
      if (!_folders.contains("Downloads")) {
        _folders.add("Downloads");
      }
      _mediaItems.insert(
        0,
        LocalMediaFile(
          id: filePath,
          title: title,
          path: filePath,
          sizeBytes: size,
          duration: const Duration(minutes: 0, seconds: 0),
          modifiedDate: mod,
          folder: "Downloads",
          isVideo: !filePath.endsWith('.mp3'),
        ),
      );
      notifyListeners();
    }
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void selectFolder(String folder) {
    _selectedFolder = folder;
    notifyListeners();
  }

  void deleteMedia(LocalMediaFile item) {
    _mediaItems.remove(item);
    if (!kIsWeb && !item.path.startsWith('http')) {
      final f = File(item.path);
      if (f.existsSync()) {
        try {
          f.deleteSync();
        } catch (_) {}
      }
    }
    notifyListeners();
  }

  String get formattedUsedStorage {
    final mb = libraryUsedBytes / (1024 * 1024);
    if (mb >= 1000) {
      return "${(mb / 1024).toStringAsFixed(1)} GB";
    }
    return "${mb.toStringAsFixed(1)} MB";
  }

  String get formattedTotalStorage {
    final gb = totalStorageBytes / (1024 * 1024 * 1024);
    return "${gb.toStringAsFixed(0)} GB";
  }
}
