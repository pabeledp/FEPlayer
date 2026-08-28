import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/media_file.dart';

class LibraryController extends ChangeNotifier {
  final List<LocalMediaFile> _mediaItems = [];
  List<LocalMediaFile> get mediaItems => _searchQuery.isEmpty
      ? _mediaItems
      : _mediaItems.where((m) => m.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  final int _totalStorageBytes = 128 * 1024 * 1024 * 1024; // 128 GB simulated capacity
  int get totalStorageBytes => _totalStorageBytes;

  int get libraryUsedBytes => _mediaItems.fold(0, (sum, item) => sum + item.sizeBytes);

  double get storageUsageFraction => (libraryUsedBytes / _totalStorageBytes).clamp(0.0, 1.0);

  final List<String> _folders = ["All Media", "Downloads", "Movies", "Music Videos", "Playlists"];
  List<String> get folders => _folders;

  String _selectedFolder = "All Media";
  String get selectedFolder => _selectedFolder;

  LibraryController() {
    _initLibrary();
  }

  void _initLibrary() {
    // Populate with demo media items
    _mediaItems.addAll([
      LocalMediaFile(
        id: "m_1",
        title: "Big Buck Bunny (1080p 60fps)",
        path: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        sizeBytes: 158 * 1024 * 1024,
        duration: const Duration(minutes: 9, seconds: 56),
        modifiedDate: DateTime.now().subtract(const Duration(hours: 2)),
        folder: "Downloads",
      ),
      LocalMediaFile(
        id: "m_2",
        title: "Elephants Dream (4K Open Movie)",
        path: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        sizeBytes: 420 * 1024 * 1024,
        duration: const Duration(minutes: 10, seconds: 54),
        modifiedDate: DateTime.now().subtract(const Duration(days: 1)),
        folder: "Movies",
      ),
      LocalMediaFile(
        id: "m_3",
        title: "For Bigger Blazes (Action Demo)",
        path: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        sizeBytes: 48 * 1024 * 1024,
        duration: const Duration(minutes: 0, seconds: 15),
        modifiedDate: DateTime.now().subtract(const Duration(days: 3)),
        folder: "Downloads",
      ),
      LocalMediaFile(
        id: "m_4",
        title: "Tears of Steel (VFX Sci-Fi Short)",
        path: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
        sizeBytes: 310 * 1024 * 1024,
        duration: const Duration(minutes: 12, seconds: 14),
        modifiedDate: DateTime.now().subtract(const Duration(days: 5)),
        folder: "Movies",
      ),
      LocalMediaFile(
        id: "m_5",
        title: "We Are Going On Bullrun (Automotive)",
        path: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
        sizeBytes: 88 * 1024 * 1024,
        duration: const Duration(minutes: 0, seconds: 47),
        modifiedDate: DateTime.now().subtract(const Duration(days: 7)),
        folder: "Music Videos",
      ),
    ]);

    _scanLocalDirectory();
  }

  Future<void> _scanLocalDirectory() async {
    if (kIsWeb) return;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}/FEPlayer_Media');
      if (await dir.exists()) {
        final files = dir.listSync();
        for (final f in files) {
          if (f is File && (f.path.endsWith('.mp4') || f.path.endsWith('.mkv') || f.path.endsWith('.mp3'))) {
            final stat = await f.stat();
            final name = f.path.split('/').last.split('\\').last;
            if (!_mediaItems.any((m) => m.path == f.path)) {
              _mediaItems.insert(
                0,
                LocalMediaFile(
                  id: f.path,
                  title: name,
                  path: f.path,
                  sizeBytes: stat.size,
                  duration: const Duration(minutes: 4, seconds: 15),
                  modifiedDate: stat.modified,
                  folder: "Downloads",
                ),
              );
            }
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error scanning local media: $e");
    }
  }

  void addDownloadedMedia(String filePath, String title) {
    _mediaItems.insert(
      0,
      LocalMediaFile(
        id: filePath,
        title: title,
        path: filePath,
        sizeBytes: 75 * 1024 * 1024,
        duration: const Duration(minutes: 3, seconds: 30),
        modifiedDate: DateTime.now(),
        folder: "Downloads",
      ),
    );
    notifyListeners();
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
