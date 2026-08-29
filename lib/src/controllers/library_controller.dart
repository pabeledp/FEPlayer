import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/media_file.dart';
import '../models/media_folder.dart';
import '../repositories/media_scanner_repository.dart';

enum MediaLibraryViewMode {
  folders,
  allMedia,
}

class LibraryController extends ChangeNotifier {
  final MediaScannerRepository _repository = MediaScannerRepository();

  MediaLibraryViewMode _viewMode = MediaLibraryViewMode.folders;
  MediaLibraryViewMode get viewMode => _viewMode;

  final List<LocalMediaFile> _allMediaItems = [];
  List<LocalMediaFile> get mediaItems {
    var items = _allMediaItems;
    if (_selectedFolder != "All Media") {
      items = items.where((m) => m.folder == _selectedFolder).toList();
    }
    if (_searchQuery.isNotEmpty) {
      items = items.where((m) => m.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return items;
  }

  Map<String, MediaFolderModel> _foldersMap = {};
  List<MediaFolderModel> get folderList {
    var list = _foldersMap.values.toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  MediaFolderModel? _currentOpenedFolder;
  MediaFolderModel? get currentOpenedFolder => _currentOpenedFolder;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPermissionGranted = true;
  bool get isPermissionGranted => _isPermissionGranted;

  bool _isPermanentlyDenied = false;
  bool get isPermanentlyDenied => _isPermanentlyDenied;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  final int _totalStorageBytes = 128 * 1024 * 1024 * 1024;
  int get totalStorageBytes => _totalStorageBytes;

  int get libraryUsedBytes => _allMediaItems.fold(0, (sum, item) => sum + item.sizeBytes);

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

  void setViewMode(MediaLibraryViewMode mode) {
    _viewMode = mode;
    _currentOpenedFolder = null;
    notifyListeners();
  }

  void openFolder(MediaFolderModel folder) {
    _currentOpenedFolder = folder;
    notifyListeners();
  }

  void closeFolder() {
    _currentOpenedFolder = null;
    notifyListeners();
  }

  Future<void> initAndScan() async {
    _isLoading = true;
    notifyListeners();

    // 1. Fast load cached media from SharedPreferences for instant UI
    final cached = await _repository.loadCachedMedia();
    if (cached.isNotEmpty) {
      _allMediaItems.clear();
      _allMediaItems.addAll(cached);
      _rebuildFolders();
      _isLoading = false;
      notifyListeners();
    }

    // 2. Check and request permissions
    final hasPermission = await checkAndRequestPermissions();
    if (hasPermission) {
      await scanDeviceVideos();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkAndRequestPermissions() async {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      _isPermissionGranted = true;
      _isPermanentlyDenied = false;
      notifyListeners();
      return true;
    }

    if (Platform.isAndroid) {
      // Android 13+ (API 33+) requires video & audio permissions
      final videoStatus = await Permission.videos.request();
      final audioStatus = await Permission.audio.request();
      final storageStatus = await Permission.storage.request();

      _isPermissionGranted = videoStatus.isGranted || storageStatus.isGranted || audioStatus.isGranted;
      _isPermanentlyDenied = videoStatus.isPermanentlyDenied && storageStatus.isPermanentlyDenied;
    } else if (Platform.isIOS) {
      final photos = await Permission.photos.request();
      _isPermissionGranted = photos.isGranted;
      _isPermanentlyDenied = photos.isPermanentlyDenied;
    }

    notifyListeners();
    return _isPermissionGranted;
  }

  Future<void> openSystemSettings() async {
    await openAppSettings();
  }

  Future<void> scanDeviceVideos() async {
    _isLoading = true;
    notifyListeners();

    final scanned = await _repository.scanDeviceStorage();
    _allMediaItems.clear();
    _allMediaItems.addAll(scanned);
    _rebuildFolders();

    _isLoading = false;
    notifyListeners();
  }

  void _rebuildFolders() {
    _foldersMap = _repository.groupMediaByFolders(_allMediaItems);
    final folderSet = <String>{"All Media"};
    for (final k in _foldersMap.keys) {
      folderSet.add(k);
    }
    _folders = folderSet.toList();

    if (_currentOpenedFolder != null) {
      _currentOpenedFolder = _foldersMap[_currentOpenedFolder!.name];
    }
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

    if (!_allMediaItems.any((m) => m.path == filePath)) {
      final isVideo = !filePath.toLowerCase().endsWith('.mp3') &&
          !filePath.toLowerCase().endsWith('.wav') &&
          !filePath.toLowerCase().endsWith('.aac') &&
          !filePath.toLowerCase().endsWith('.flac') &&
          !filePath.toLowerCase().endsWith('.m4a');

      final newFile = LocalMediaFile(
        id: filePath,
        title: title,
        path: filePath,
        sizeBytes: size,
        duration: const Duration(minutes: 0, seconds: 0),
        modifiedDate: mod,
        folder: "Downloads",
        isVideo: isVideo,
      );

      _allMediaItems.insert(0, newFile);
      _rebuildFolders();
      _repository.saveMediaCache(_allMediaItems);
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
    _allMediaItems.remove(item);
    _rebuildFolders();
    _repository.saveMediaCache(_allMediaItems);

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
    if (mb >= 1024) {
      return "${(mb / 1024).toStringAsFixed(1)} GB";
    }
    return "${mb.toStringAsFixed(1)} MB";
  }

  String get formattedTotalStorage {
    final gb = totalStorageBytes / (1024 * 1024 * 1024);
    return "${gb.toStringAsFixed(0)} GB";
  }
}
