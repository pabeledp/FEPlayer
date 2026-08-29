import 'media_file.dart';

enum FolderContentType {
  videoOnly,
  audioOnly,
  mixed,
}

class MediaFolderModel {
  final String name;
  final String path;
  final List<LocalMediaFile> files;

  MediaFolderModel({
    required this.name,
    required this.path,
    required this.files,
  });

  int get itemCount => files.length;

  int get totalSizeBytes => files.fold(0, (sum, f) => sum + f.sizeBytes);

  int get videoCount => files.where((f) => f.isVideo).length;
  int get audioCount => files.where((f) => !f.isVideo).length;

  FolderContentType get contentType {
    if (videoCount > 0 && audioCount == 0) return FolderContentType.videoOnly;
    if (audioCount > 0 && videoCount == 0) return FolderContentType.audioOnly;
    return FolderContentType.mixed;
  }

  String get typeLabel {
    switch (contentType) {
      case FolderContentType.videoOnly:
        return "Video";
      case FolderContentType.audioOnly:
        return "Audio";
      case FolderContentType.mixed:
        return "Mixed";
    }
  }

  String get formattedTotalSize {
    final mb = totalSizeBytes / (1024 * 1024);
    if (mb >= 1024) {
      return "${(mb / 1024).toStringAsFixed(1)} GB";
    }
    return "${mb.toStringAsFixed(1)} MB";
  }

  String get summaryBadge => "$itemCount ${itemCount == 1 ? 'File' : 'Files'} • $formattedTotalSize";

  LocalMediaFile? get representativeMedia => files.isNotEmpty ? files.first : null;
}
