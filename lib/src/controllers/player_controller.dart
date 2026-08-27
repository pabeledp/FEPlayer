import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  Duration _buffer = Duration.zero;
  Duration get buffer => _buffer;

  double _volume = 0.8;
  double get volume => _volume;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  String _fileName = "No File Loaded";
  String get fileName => _fileName;

  bool _controlsVisible = true;
  bool get controlsVisible => _controlsVisible;

  bool _isFullscreen = false;
  bool get isFullscreen => _isFullscreen;

  // Sidebar visibility (VLC-style library)
  bool _sidebarVisible = false;
  bool get sidebarVisible => _sidebarVisible;

  // Playlist & Library
  final List<PlaylistItem> _playlist = [];
  List<PlaylistItem> get playlist => _playlist;
  int _currentPlaylistIndex = -1;
  int get currentPlaylistIndex => _currentPlaylistIndex;

  // Audio Tracks (Dual Language support) & Subtitles
  Tracks _tracks = const Tracks();
  Tracks get tracks => _tracks;
  AudioTrack _selectedAudioTrack = AudioTrack.auto();
  AudioTrack get selectedAudioTrack => _selectedAudioTrack;
  SubtitleTrack _selectedSubtitleTrack = SubtitleTrack.auto();
  SubtitleTrack get selectedSubtitleTrack => _selectedSubtitleTrack;

  // HUD overlays
  bool _showVolumeHud = false;
  bool get showVolumeHud => _showVolumeHud;

  bool _showPlayPauseOverlay = false;
  bool get showPlayPauseOverlay => _showPlayPauseOverlay;
  bool _isOverlayPlayIcon = false;
  bool get isOverlayPlayIcon => _isOverlayPlayIcon;

  bool _showSeekLeftFeedback = false;
  bool get showSeekLeftFeedback => _showSeekLeftFeedback;
  bool _showSeekRightFeedback = false;
  bool get showSeekRightFeedback => _showSeekRightFeedback;

  Timer? _hideControlsTimer;
  Timer? _overlayTimer;
  Timer? _volumeHudTimer;
  Timer? _seekLeftTimer;
  Timer? _seekRightTimer;

  FEPlayerController() {
    _initPlayer();
  }

  void _initPlayer() {
    player = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 32 * 1024 * 1024,
      ),
    );
    videoController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );

    player.stream.playing.listen((playing) {
      _isPlaying = playing;
      if (playing) {
        _startHideControlsTimer();
      } else {
        _cancelHideControlsTimer();
        _controlsVisible = true;
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
      notifyListeners();
    });

    player.stream.tracks.listen((trks) {
      _tracks = trks;
      _selectedAudioTrack = trks.audio.firstWhere(
        (t) => t.id == player.state.track.audio.id,
        orElse: () => AudioTrack.auto(),
      );
      _selectedSubtitleTrack = trks.subtitle.firstWhere(
        (t) => t.id == player.state.track.subtitle.id,
        orElse: () => SubtitleTrack.auto(),
      );
      notifyListeners();
    });

    player.stream.track.listen((track) {
      _selectedAudioTrack = track.audio;
      _selectedSubtitleTrack = track.subtitle;
      notifyListeners();
    });

    // Populate initial demo playlist
    _playlist.addAll([
      PlaylistItem(
        title: "Big Buck Bunny (1080p Multi-Audio Demo)",
        pathOrUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        isNetwork: true,
      ),
      PlaylistItem(
        title: "Elephants Dream (Open Movie)",
        pathOrUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        isNetwork: true,
      ),
      PlaylistItem(
        title: "For Bigger Blazes (HD Test Stream)",
        pathOrUrl: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        isNetwork: true,
      ),
    ]);

    _isInitialized = true;
    notifyListeners();
  }

  void toggleSidebar() {
    _sidebarVisible = !_sidebarVisible;
    notifyListeners();
  }

  // Mouse moves inside window: show controls and reset 2s inactivity timer
  void onUserInteraction() {
    if (!_controlsVisible) {
      _controlsVisible = true;
      notifyListeners();
    }
    if (_isPlaying) {
      _startHideControlsTimer();
    }
  }

  // Mouse leaves the entire screen/window: immediately hide controls
  void onMouseExitScreen() {
    if (_isPlaying && !_sidebarVisible) {
      _cancelHideControlsTimer();
      _controlsVisible = false;
      notifyListeners();
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 2), () {
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

  Future<void> seekRelative(int seconds) async {
    final newPos = _position + Duration(seconds: seconds);
    await seek(newPos);

    if (seconds < 0) {
      _showSeekLeftFeedback = true;
      _seekLeftTimer?.cancel();
      _seekLeftTimer = Timer(const Duration(milliseconds: 500), () {
        _showSeekLeftFeedback = false;
        notifyListeners();
      });
    } else {
      _showSeekRightFeedback = true;
      _seekRightTimer?.cancel();
      _seekRightTimer = Timer(const Duration(milliseconds: 500), () {
        _showSeekRightFeedback = false;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  // Volume & Keyboard Up/Down Control with HUD
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    _isMuted = _volume == 0.0;
    await player.setVolume(_volume * 100.0);
    
    // Trigger on-screen Volume HUD
    _showVolumeHud = true;
    notifyListeners();
    _volumeHudTimer?.cancel();
    _volumeHudTimer = Timer(const Duration(milliseconds: 1200), () {
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
    _volumeHudTimer = Timer(const Duration(milliseconds: 1200), () {
      _showVolumeHud = false;
      notifyListeners();
    });
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

  // Fullscreen
  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    notifyListeners();
  }

  // Open Local File (Universal for Web & Desktop)
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
        seekRelative(-5);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        seekRelative(5);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        adjustVolume(0.05); // Volume UP +5% with on-screen HUD
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        adjustVolume(-0.05); // Volume DOWN -5% with on-screen HUD
      } else if (event.logicalKey == LogicalKeyboardKey.keyL) {
        toggleSidebar(); // Toggle Library / Playlist sidebar
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
    _seekLeftTimer?.cancel();
    _seekRightTimer?.cancel();
    player.dispose();
    super.dispose();
  }
}
