import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:file_picker/file_picker.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:window_manager/window_manager.dart';

class PlaylistItem {
  final String title;
  final String pathOrUrl;
  final bool isNetwork;

  PlaylistItem({
    required this.title,
    required this.pathOrUrl,
    this.isNetwork = false,
  });
}

class FEPlayerController extends ChangeNotifier {
  late final Player player;
  late final VideoController videoController;

  // Playback State
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  Duration _buffer = Duration.zero;
  Duration get buffer => _buffer;

  // Volume (0.0 - 1.0)
  double _volume = 1.0;
  double get volume => _volume;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  // Screen Brightness (0.0 - 1.0)
  double _brightness = 0.6;
  double get brightness => _brightness;

  bool _showBrightnessHud = false;
  bool get showBrightnessHud => _showBrightnessHud;
  Timer? _brightnessHudTimer;

  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  String _fileName = "No File Loaded";
  String get fileName => _fileName;

  bool _isFullscreen = false;
  bool get isFullscreen => _isFullscreen;

  // Active Player View Visibility (Overlay vs Home Library)
  bool _isPlayerActive = false;
  bool get isPlayerActive => _isPlayerActive;
  bool get isInitialized => true;

  // Auto-hide Controls State (3s inactivity timer)
  bool _controlsVisible = true;
  bool get controlsVisible => _controlsVisible;
  Timer? _hideControlsTimer;

  // Side Drawer (Playlist / Queue)
  bool _sidebarVisible = false;
  bool get sidebarVisible => _sidebarVisible;

  // Audio & Subtitle Tracks (Dual-language support)
  Tracks _tracks = const Tracks();
  Tracks get tracks => _tracks;

  AudioTrack _selectedAudioTrack = AudioTrack.auto();
  AudioTrack get selectedAudioTrack => _selectedAudioTrack;

  SubtitleTrack _selectedSubtitleTrack = SubtitleTrack.auto();
  SubtitleTrack get selectedSubtitleTrack => _selectedSubtitleTrack;

  // Playlist & Queue
  final List<PlaylistItem> _playlist = [];
  List<PlaylistItem> get playlist => _playlist;
  int _currentPlaylistIndex = -1;
  int get currentPlaylistIndex => _currentPlaylistIndex;

  // Visual Gesture Overlays (Double Tap -10s / +10s)
  bool _showPlayPauseOverlay = false;
  bool get showPlayPauseOverlay => _showPlayPauseOverlay;
  bool _isOverlayPlayIcon = false;
  bool get isOverlayPlayIcon => _isOverlayPlayIcon;
  Timer? _overlayTimer;

  bool _showVolumeHud = false;
  bool get showVolumeHud => _showVolumeHud;
  Timer? _volumeHudTimer;

  bool _showSeekLeftFeedback = false;
  bool get showSeekLeftFeedback => _showSeekLeftFeedback;
  Timer? _seekLeftTimer;

  bool _showSeekRightFeedback = false;
  bool get showSeekRightFeedback => _showSeekRightFeedback;
  Timer? _seekRightTimer;

  // Horizontal Drag Seeking State
  bool _isDraggingSeek = false;
  bool get isDraggingSeek => _isDraggingSeek;
  Duration _dragSeekTarget = Duration.zero;
  Duration get dragSeekTarget => _dragSeekTarget;

  FEPlayerController() {
    _initPlayer();
    _initBrightness();
  }

  void _initPlayer() {
    player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 64 * 1024 * 1024, // 64MB buffer for ultra-smooth 4K 60fps
        logLevel: MPVLogLevel.warn,
        ready: null,
      ),
    );
    videoController = VideoController(player);

    // Listen to player state streams
    player.stream.playing.listen((playing) {
      _isPlaying = playing;
      if (playing) {
        _startHideControlsTimer();
      } else {
        _controlsVisible = true;
        _cancelHideControlsTimer();
      }
      notifyListeners();
    });

    player.stream.position.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    player.stream.duration.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    player.stream.buffer.listen((buf) {
      _buffer = buf;
      notifyListeners();
    });

    player.stream.volume.listen((vol) {
      _volume = vol / 100.0;
      _isMuted = _volume == 0.0;
      notifyListeners();
    });

    player.stream.tracks.listen((tracks) {
      _tracks = tracks;
      _selectedAudioTrack = player.state.track.audio;
      _selectedSubtitleTrack = player.state.track.subtitle;
      notifyListeners();
    });

    player.stream.rate.listen((rate) {
      _playbackSpeed = rate;
      notifyListeners();
    });
  }

  Future<void> _initBrightness() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        _brightness = await ScreenBrightness().application;
        notifyListeners();
      }
    } catch (_) {}
  }

  void openPlayer() {
    _isPlayerActive = true;
    _controlsVisible = true;
    _startHideControlsTimer();
    notifyListeners();
  }

  void closePlayer() {
    player.pause();
    _isPlayerActive = false;
    _restoreOrientationAndBars();
    notifyListeners();
  }

  // Sidebar toggle
  void toggleSidebar() {
    _sidebarVisible = !_sidebarVisible;
    if (_sidebarVisible) {
      _controlsVisible = true;
      _cancelHideControlsTimer();
    } else if (_isPlaying) {
      _startHideControlsTimer();
    }
    notifyListeners();
  }

  // Auto-hide controls timer logic (3 seconds timeout)
  void onUserInteraction() {
    if (!_controlsVisible) {
      _controlsVisible = true;
      notifyListeners();
    }
    if (_isPlaying && !_sidebarVisible) {
      _startHideControlsTimer();
    }
  }

  void onMouseExitScreen() {
    if (_isPlaying && !_sidebarVisible) {
      _cancelHideControlsTimer();
      _controlsVisible = false;
      notifyListeners();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && !_sidebarVisible) {
        _controlsVisible = false;
        notifyListeners();
      }
    });
  }

  void _cancelHideControlsTimer() {
    _hideControlsTimer?.cancel();
  }

  void toggleControlsVisibility() {
    _controlsVisible = !_controlsVisible;
    if (_controlsVisible && _isPlaying) {
      _startHideControlsTimer();
    }
    notifyListeners();
  }

  // Play / Pause toggle
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await player.pause();
      _triggerPlayPauseOverlay(false);
    } else {
      if (_fileName == "No File Loaded" && _playlist.isNotEmpty) {
        await playPlaylistItem(0);
      } else {
        await player.play();
        _triggerPlayPauseOverlay(true);
      }
    }
    notifyListeners();
  }

  void _triggerPlayPauseOverlay(bool isPlay) {
    _isOverlayPlayIcon = isPlay;
    _showPlayPauseOverlay = true;
    notifyListeners();

    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(milliseconds: 650), () {
      _showPlayPauseOverlay = false;
      notifyListeners();
    });
  }

  // Seek
  Future<void> seek(Duration targetPosition) async {
    final clamped = targetPosition < Duration.zero
        ? Duration.zero
        : (targetPosition > _duration ? _duration : targetPosition);
    await player.seek(clamped);
  }

  // Double-tap Seek (-10s / +10s)
  Future<void> seekRelative(int seconds) async {
    final newPos = _position + Duration(seconds: seconds);
    await seek(newPos);

    if (seconds < 0) {
      _showSeekLeftFeedback = true;
      _seekLeftTimer?.cancel();
      _seekLeftTimer = Timer(const Duration(milliseconds: 650), () {
        _showSeekLeftFeedback = false;
        notifyListeners();
      });
    } else {
      _showSeekRightFeedback = true;
      _seekRightTimer?.cancel();
      _seekRightTimer = Timer(const Duration(milliseconds: 650), () {
        _showSeekRightFeedback = false;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  // Horizontal Drag to Seek
  void startHorizontalSeek(Duration currentPos) {
    _isDraggingSeek = true;
    _dragSeekTarget = currentPos;
    _cancelHideControlsTimer();
    _controlsVisible = true;
    notifyListeners();
  }

  void updateHorizontalSeek(double deltaSeconds) {
    final newSecs = (_dragSeekTarget.inSeconds + deltaSeconds).clamp(0, _duration.inSeconds.toDouble());
    _dragSeekTarget = Duration(seconds: newSecs.toInt());
    notifyListeners();
  }

  Future<void> endHorizontalSeek() async {
    if (_isDraggingSeek) {
      await seek(_dragSeekTarget);
      _isDraggingSeek = false;
      if (_isPlaying) {
        _startHideControlsTimer();
      }
      notifyListeners();
    }
  }

  // Volume Gesture (0.0 - 1.0) with Vertical Glass HUD
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    _isMuted = _volume == 0.0;
    await player.setVolume(_volume * 100.0);
    
    // Trigger Vertical Volume HUD
    _showVolumeHud = true;
    notifyListeners();
    _volumeHudTimer?.cancel();
    _volumeHudTimer = Timer(const Duration(milliseconds: 1500), () {
      _showVolumeHud = false;
      notifyListeners();
    });
  }

  Future<void> adjustVolume(double delta) async {
    await setVolume(_volume + delta);
  }

  Future<void> toggleMute() async {
    if (_isMuted) {
      _isMuted = false;
      await player.setVolume((_volume > 0 ? _volume : 0.5) * 100.0);
    } else {
      _isMuted = true;
      await player.setVolume(0);
    }
    _showVolumeHud = true;
    notifyListeners();
    _volumeHudTimer?.cancel();
    _volumeHudTimer = Timer(const Duration(milliseconds: 1500), () {
      _showVolumeHud = false;
      notifyListeners();
    });
  }

  // Brightness Gesture (0.0 - 1.0) with Vertical Glass HUD
  Future<void> setBrightness(double value) async {
    _brightness = value.clamp(0.05, 1.0);
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await ScreenBrightness().setApplicationScreenBrightness(_brightness);
      }
    } catch (_) {}

    // Trigger Vertical Brightness HUD
    _showBrightnessHud = true;
    notifyListeners();
    _brightnessHudTimer?.cancel();
    _brightnessHudTimer = Timer(const Duration(milliseconds: 1500), () {
      _showBrightnessHud = false;
      notifyListeners();
    });
  }

  Future<void> adjustBrightness(double delta) async {
    await setBrightness(_brightness + delta);
  }

  // Fullscreen & Orientation Switching
  Future<void> toggleFullscreen() async {
    _isFullscreen = !_isFullscreen;

    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      await windowManager.setFullScreen(_isFullscreen);
    } else {
      // Mobile Responsive Orientation & System UI Mode
      if (_isFullscreen) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        await _restoreOrientationAndBars();
      }
    }
    notifyListeners();
  }

  Future<void> _restoreOrientationAndBars() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  // Playback Rate / Speed
  Future<void> setPlaybackRate(double speed) async {
    _playbackSpeed = speed;
    await player.setRate(speed);
    notifyListeners();
  }

  // Audio Track / Dual Language Switching
  Future<void> setAudioTrack(AudioTrack track) async {
    _selectedAudioTrack = track;
    await player.setAudioTrack(track);
    notifyListeners();
  }

  // Subtitle Track Switching
  Future<void> setSubtitleTrack(SubtitleTrack track) async {
    _selectedSubtitleTrack = track;
    await player.setSubtitleTrack(track);
    notifyListeners();
  }

  // Load external subtitle (.srt / .vtt)
  Future<void> loadExternalSubtitle() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt', 'ass', 'ssa'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      if (!kIsWeb && file.path != null) {
        await player.setSubtitleTrack(SubtitleTrack.uri(file.path!, title: file.name));
        notifyListeners();
      }
    }
  }

  // Playlist management
  Future<void> playPlaylistItem(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentPlaylistIndex = index;
      final item = _playlist[index];
      await loadMedia(item.pathOrUrl, name: item.title);
    }
  }

  void addToPlaylist(String pathOrUrl, String title, {bool isNetwork = false}) {
    _playlist.add(PlaylistItem(title: title, pathOrUrl: pathOrUrl, isNetwork: isNetwork));
    notifyListeners();
  }

  void removeFromPlaylist(int index) {
    if (index >= 0 && index < _playlist.length) {
      _playlist.removeAt(index);
      if (_currentPlaylistIndex == index) {
        _currentPlaylistIndex = -1;
      }
      notifyListeners();
    }
  }

  // Open Local File
  Future<void> openFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        withData: kIsWeb,
        allowedExtensions: ['mp4', 'mkv', 'avi', 'mov', 'webm', 'flv', 'wmv', 'mp3', 'm4v', 'ts'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        _fileName = file.name;
        notifyListeners();

        if (kIsWeb) {
          if (file.bytes != null) {
            final dataUri = Uri.dataFromBytes(file.bytes!, mimeType: 'video/mp4').toString();
            addToPlaylist(dataUri, file.name, isNetwork: false);
            _currentPlaylistIndex = _playlist.length - 1;
            await loadMedia(dataUri, name: file.name);
          }
        } else {
          if (file.path != null) {
            addToPlaylist(file.path!, file.name, isNetwork: false);
            _currentPlaylistIndex = _playlist.length - 1;
            await loadMedia(file.path!, name: file.name);
          }
        }
      }
    } catch (e) {
      debugPrint("File picker error: $e");
    }
  }

  // Load URL or File Path
  Future<void> loadMedia(String pathOrUrl, {String? name}) async {
    _fileName = name ?? pathOrUrl.split('/').last.split('\\').last;
    _isPlayerActive = true;
    _controlsVisible = true;
    _startHideControlsTimer();
    notifyListeners();
    await player.open(Media(pathOrUrl));
    await player.play();
    notifyListeners();
  }

  // Handle Keyboard Shortcuts
  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        togglePlayPause();
      } else if (event.logicalKey == LogicalKeyboardKey.keyF ||
          event.logicalKey == LogicalKeyboardKey.f11) {
        toggleFullscreen();
      } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
        toggleMute();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        seekRelative(-10); // -10s
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        seekRelative(10); // +10s
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        adjustVolume(0.05); // Volume +5%
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        adjustVolume(-0.05); // Volume -5%
      } else if (event.logicalKey == LogicalKeyboardKey.keyL) {
        toggleSidebar();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (_isPlayerActive) {
          closePlayer();
        }
      }
    }
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _overlayTimer?.cancel();
    _volumeHudTimer?.cancel();
    _brightnessHudTimer?.cancel();
    _seekLeftTimer?.cancel();
    _seekRightTimer?.cancel();
    player.dispose();
    super.dispose();
  }
}
