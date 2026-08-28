class LocalMediaFile {
  final String id;
  final String title;
  final String path;
  final int sizeBytes;
  final Duration duration;
  final DateTime modifiedDate;
  final String? folder;
  final bool isVideo;

  LocalMediaFile({
    required this.id,
    required this.title,
    required this.path,
    required this.sizeBytes,
    required this.duration,
    required this.modifiedDate,
    this.folder,
    this.isVideo = true,
  });

  String get formattedSize {
    final mb = sizeBytes / (1024 * 1024);
    if (mb >= 1000) {
      return "${(mb / 1024).toStringAsFixed(1)} GB";
    }
    return "${mb.toStringAsFixed(1)} MB";
  }

  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return "$hours:${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }
}
