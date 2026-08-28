enum DownloadStatus { idle, fetching, downloading, paused, completed, failed, merging }
enum DownloadFormat { videoMp4, audioMp3 }

class DownloadResolution {
  final String label; // "480p", "720p", "1080p", "1440p (2K)", "2160p (4K)"
  final int height;
  final String qualityLabel;
  final int approxSizeBytes;
  final bool isVideoOnly; // Needs audio muxing if > 720p

  DownloadResolution({
    required this.label,
    required this.height,
    required this.qualityLabel,
    required this.approxSizeBytes,
    this.isVideoOnly = false,
  });

  String get formattedSize {
    if (approxSizeBytes <= 0) return "~MB";
    final mb = approxSizeBytes / (1024 * 1024);
    if (mb >= 1000) {
      return "${(mb / 1024).toStringAsFixed(1)} GB";
    }
    return "${mb.toStringAsFixed(1)} MB";
  }
}

class DownloadMetadata {
  final String id;
  final String title;
  final String author;
  final String thumbnailUrl;
  final Duration duration;
  final String sourceUrl;
  final List<DownloadResolution> availableResolutions;

  DownloadMetadata({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.duration,
    required this.sourceUrl,
    required this.availableResolutions,
  });

  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    final hours = duration.inHours;
    if (hours > 0) {
      return "$hours:${twoDigits(minutes.remainder(60))}:${twoDigits(seconds)}";
    }
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }
}

class ActiveDownload {
  final String id;
  final DownloadMetadata metadata;
  final DownloadFormat format;
  final DownloadResolution resolution;
  DownloadStatus status;
  double progress; // 0.0 to 1.0
  double speedBytesPerSec;
  int downloadedBytes;
  int totalBytes;
  String? savePath;
  String? errorMessage;

  ActiveDownload({
    required this.id,
    required this.metadata,
    required this.format,
    required this.resolution,
    this.status = DownloadStatus.downloading,
    this.progress = 0.0,
    this.speedBytesPerSec = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.savePath,
    this.errorMessage,
  });

  String get formattedSpeed {
    final mbps = speedBytesPerSec / (1024 * 1024);
    if (mbps >= 1.0) {
      return "${mbps.toStringAsFixed(1)} MB/s";
    }
    final kbps = speedBytesPerSec / 1024;
    return "${kbps.toStringAsFixed(0)} KB/s";
  }

  String get formattedProgress {
    return "${(progress * 100).toStringAsFixed(0)}%";
  }

  String get formattedDownloaded {
    final curMb = downloadedBytes / (1024 * 1024);
    final totMb = totalBytes / (1024 * 1024);
    if (totMb >= 1000) {
      return "${(curMb / 1024).toStringAsFixed(2)} / ${(totMb / 1024).toStringAsFixed(2)} GB";
    }
    return "${curMb.toStringAsFixed(1)} / ${totMb.toStringAsFixed(1)} MB";
  }

  String get eta {
    if (speedBytesPerSec <= 0 || progress <= 0) return "--:--";
    final remainingBytes = totalBytes - downloadedBytes;
    if (remainingBytes <= 0) return "00:00";
    final remainingSecs = (remainingBytes / speedBytesPerSec).round();
    final mins = remainingSecs ~/ 60;
    final secs = remainingSecs % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }
}
