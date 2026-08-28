import 'package:audio_service/audio_service.dart';


class FEAudioHandler extends BaseAudioHandler with SeekHandler {
  Function()? onPlayAction;
  Function()? onPauseAction;
  Function(Duration position)? onSeekAction;
  Function()? onStopAction;

  FEAudioHandler() {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.rewind,
          MediaControl.play,
          MediaControl.fastForward,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  void updateMedia({
    required String title,
    required String artist,
    required Duration duration,
    required Duration position,
    required bool isPlaying,
    double speed = 1.0,
  }) {
    mediaItem.add(
      MediaItem(
        id: title,
        album: "FE Player",
        title: title,
        artist: artist,
        duration: duration,
      ),
    );

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.rewind,
          isPlaying ? MediaControl.pause : MediaControl.play,
          MediaControl.fastForward,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.ready,
        playing: isPlaying,
        updatePosition: position,
        speed: speed,
      ),
    );
  }

  @override
  Future<void> play() async {
    if (onPlayAction != null) onPlayAction!();
  }

  @override
  Future<void> pause() async {
    if (onPauseAction != null) onPauseAction!();
  }

  @override
  Future<void> seek(Duration position) async {
    if (onSeekAction != null) onSeekAction!(position);
  }

  @override
  Future<void> stop() async {
    if (onStopAction != null) onStopAction!();
  }

  @override
  Future<void> rewind() async {
    final cur = playbackState.value.position;
    final target = cur - const Duration(seconds: 10);
    seek(target < Duration.zero ? Duration.zero : target);
  }

  @override
  Future<void> fastForward() async {
    final cur = playbackState.value.position;
    seek(cur + const Duration(seconds: 10));
  }
}
