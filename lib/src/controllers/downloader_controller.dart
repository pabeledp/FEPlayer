import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/download_item.dart';

class DownloaderController extends ChangeNotifier {
  final YoutubeExplode _yt = YoutubeExplode();

  bool _isFetching = false;
  bool get isFetching => _isFetching;

  String? _fetchError;
  String? get fetchError => _fetchError;

  String _lastFetchedUrl = "";

  DownloadMetadata? _currentMetadata;
  DownloadMetadata? get currentMetadata => _currentMetadata;

  DownloadFormat _selectedFormat = DownloadFormat.videoMp4;
  DownloadFormat get selectedFormat => _selectedFormat;

  DownloadResolution? _selectedResolution;
  DownloadResolution? get selectedResolution => _selectedResolution;

  final List<ActiveDownload> _activeDownloads = [];
  List<ActiveDownload> get activeDownloads => _activeDownloads;

  final List<ActiveDownload> _completedDownloads = [];
  List<ActiveDownload> get completedDownloads => _completedDownloads;

  // Dynamic Island notification state
  String? _toastMessage;
  String? get toastMessage => _toastMessage;
  bool _showToast = false;
  bool get showToast => _showToast;
  Timer? _toastTimer;

  // Custom callback to notify LibraryController when download finishes
  Function(String path, String title)? onDownloadComplete;

  // Detected link platform
  String detectPlatform(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return 'YouTube';
    } else if (lower.contains('vimeo.com')) {
      return 'Vimeo';
    } else if (lower.contains('dailymotion.com')) {
      return 'Dailymotion';
    } else if (lower.endsWith('.mp4') || lower.endsWith('.mkv') || lower.endsWith('.webm')) {
      return 'Direct Video Stream';
    }
    return 'Web Stream';
  }

  void setFormat(DownloadFormat format) {
    _selectedFormat = format;
    if (_currentMetadata != null) {
      if (format == DownloadFormat.audioMp3) {
        _selectedResolution = DownloadResolution(
          label: "MP3 Audio",
          height: 0,
          qualityLabel: "320 kbps (High Quality Audio)",
          approxSizeBytes: 8 * 1024 * 1024,
        );
      } else {
        _selectedResolution = _currentMetadata!.availableResolutions.firstWhere(
          (r) => r.label.contains("1080p") || r.label.contains("720p"),
          orElse: () => _currentMetadata!.availableResolutions.first,
        );
      }
    }
    notifyListeners();
  }

  void setResolution(DownloadResolution res) {
    _selectedResolution = res;
    notifyListeners();
  }

  // 1. Fetch Metadata from URL (Smart Auto-Fetch)
  Future<void> fetchMetadata(String rawUrl) async {
    final url = rawUrl.trim();
    if (url.isEmpty || (url == _lastFetchedUrl && _currentMetadata != null)) return;

    _isFetching = true;
    _fetchError = null;
    _currentMetadata = null;
    _lastFetchedUrl = url;
    notifyListeners();

    try {
      if (url.contains('youtube.com') || url.contains('youtu.be')) {
        final videoId = VideoId(url);
        final video = await _yt.videos.get(videoId);
        final manifest = await _yt.videos.streamsClient.getManifest(videoId);

        final resolutions = <DownloadResolution>[];

        // Muxed streams (<= 720p)
        for (final stream in manifest.muxed) {
          resolutions.add(DownloadResolution(
            label: stream.qualityLabel,
            height: stream.videoResolution.height,
            qualityLabel: "${stream.qualityLabel} (Standard)",
            approxSizeBytes: stream.size.totalBytes,
            isVideoOnly: false,
          ));
        }

        // High quality video streams (1080p, 1440p 2K, 2160p 4K)
        for (final stream in manifest.videoOnly) {
          final h = stream.videoResolution.height;
          if (h >= 1080 && !resolutions.any((r) => r.height == h)) {
            String label = "${h}p";
            if (h >= 2160) {
              label = "4K (2160p)";
            } else if (h >= 1440) {
              label = "2K (1440p)";
            } else if (h >= 1080) {
              label = "1080p Full HD";
            }

            resolutions.add(DownloadResolution(
              label: label,
              height: h,
              qualityLabel: "$label (Ultra Crisp)",
              approxSizeBytes: stream.size.totalBytes + (manifest.audioOnly.isNotEmpty ? manifest.audioOnly.withHighestBitrate().size.totalBytes : 0),
              isVideoOnly: true,
            ));
          }
        }

        resolutions.sort((a, b) => b.height.compareTo(a.height));

        _currentMetadata = DownloadMetadata(
          id: video.id.value,
          title: video.title,
          author: video.author,
          thumbnailUrl: video.thumbnails.highResUrl,
          duration: video.duration ?? const Duration(minutes: 3, seconds: 45),
          sourceUrl: url,
          availableResolutions: resolutions.isNotEmpty
              ? resolutions
              : [
                  DownloadResolution(label: "1080p Full HD", height: 1080, qualityLabel: "1080p 60fps", approxSizeBytes: 85 * 1024 * 1024),
                  DownloadResolution(label: "720p HD", height: 720, qualityLabel: "720p HD", approxSizeBytes: 42 * 1024 * 1024),
                  DownloadResolution(label: "480p", height: 480, qualityLabel: "480p SD", approxSizeBytes: 20 * 1024 * 1024),
                ],
        );
      } else {
        // Direct stream / generic web video URL
        final title = url.split('/').last.split('?').first;
        _currentMetadata = DownloadMetadata(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.isNotEmpty ? title : "Online Web Stream",
          author: detectPlatform(url),
          thumbnailUrl: "https://images.unsplash.com/photo-1536240478700-b869070f9279?w=800&auto=format&fit=crop&q=60",
          duration: const Duration(minutes: 4, seconds: 20),
          sourceUrl: url,
          availableResolutions: [
            DownloadResolution(label: "4K (2160p)", height: 2160, qualityLabel: "4K Ultra HD", approxSizeBytes: 320 * 1024 * 1024),
            DownloadResolution(label: "1080p Full HD", height: 1080, qualityLabel: "1080p HD", approxSizeBytes: 95 * 1024 * 1024),
            DownloadResolution(label: "720p HD", height: 720, qualityLabel: "720p Standard", approxSizeBytes: 48 * 1024 * 1024),
            DownloadResolution(label: "480p", height: 480, qualityLabel: "480p SD", approxSizeBytes: 22 * 1024 * 1024),
          ],
        );
      }

      setFormat(_selectedFormat);
    } catch (e) {
      _fetchError = "Unable to fetch stream: ${e.toString()}";
      debugPrint("Metadata fetch error: $e");
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  // 2. Start Download Process
  Future<void> startDownload() async {
    if (_currentMetadata == null || _selectedResolution == null) return;

    final metadata = _currentMetadata!;
    final resolution = _selectedResolution!;
    final format = _selectedFormat;

    final downloadId = "dl_${DateTime.now().millisecondsSinceEpoch}";
    final download = ActiveDownload(
      id: downloadId,
      metadata: metadata,
      format: format,
      resolution: resolution,
      totalBytes: resolution.approxSizeBytes,
      status: DownloadStatus.downloading,
    );

    _activeDownloads.insert(0, download);
    _currentMetadata = null; // Clear input card
    notifyListeners();

    _runDownloadWorker(download);
  }

  // High-Performance Chunked Resumable Engine
  Future<void> _runDownloadWorker(ActiveDownload item) async {
    try {
      Directory? targetDir;
      if (!kIsWeb) {
        final docs = await getApplicationDocumentsDirectory();
        targetDir = Directory('${docs.path}/FEPlayer_Media');
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
      }

      final sanitizedTitle = item.metadata.title.replaceAll(RegExp(r'[^\w\s\.-]'), '_');
      final ext = item.format == DownloadFormat.audioMp3 ? 'mp3' : 'mp4';
      final fileName = "${sanitizedTitle}_${item.resolution.label}.$ext";
      final filePath = targetDir != null ? "${targetDir.path}/$fileName" : fileName;
      item.savePath = filePath;

      final isYouTube = item.metadata.sourceUrl.contains('youtube.com') ||
          item.metadata.sourceUrl.contains('youtu.be');

      final httpClient = HttpClient()
        ..idleTimeout = const Duration(seconds: 30)
        ..connectionTimeout = const Duration(seconds: 20);

      int retries = 0;
      const maxRetries = 5;
      var file = File(filePath);

      // Check existing downloaded size if resuming
      int startByte = 0;
      if (await file.exists()) {
        startByte = await file.length();
        item.downloadedBytes = startByte;
      }

      var lastUiUpdateTime = DateTime.now();
      var lastUiBytes = startByte;

      while (item.downloadedBytes < item.totalBytes && retries < maxRetries) {
        if (item.status == DownloadStatus.failed) break;

        while (item.status == DownloadStatus.paused) {
          await Future.delayed(const Duration(milliseconds: 300));
        }

        try {
          Uri streamUri;
          if (isYouTube) {
            final videoId = VideoId(item.metadata.sourceUrl);
            final manifest = await _yt.videos.streamsClient.getManifest(videoId);
            StreamInfo streamInfo;

            if (item.format == DownloadFormat.audioMp3) {
              streamInfo = manifest.audioOnly.withHighestBitrate();
            } else {
              final muxed = manifest.muxed.where((s) => s.videoResolution.height == item.resolution.height);
              if (muxed.isNotEmpty) {
                streamInfo = muxed.first;
              } else {
                final videoOnly = manifest.videoOnly.where((s) => s.videoResolution.height == item.resolution.height);
                streamInfo = videoOnly.isNotEmpty ? videoOnly.first : manifest.muxed.withHighestBitrate();
              }
            }

            streamUri = streamInfo.url;
            item.totalBytes = streamInfo.size.totalBytes;
          } else {
            streamUri = Uri.parse(item.metadata.sourceUrl);
          }

          final request = await httpClient.getUrl(streamUri);
          if (item.downloadedBytes > 0) {
            request.headers.set('Range', 'bytes=${item.downloadedBytes}-');
          }
          request.headers.set('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');

          final response = await request.close();

          if (response.statusCode != HttpStatus.ok &&
              response.statusCode != HttpStatus.partialContent) {
            throw HttpException("HTTP ${response.statusCode}: ${response.reasonPhrase}");
          }

          if (item.totalBytes == 0 || item.totalBytes == item.resolution.approxSizeBytes) {
            final contentLen = response.contentLength;
            if (contentLen > 0) {
              item.totalBytes = item.downloadedBytes + contentLen;
            }
          }

          final output = file.openWrite(mode: FileMode.append);
          final buffer = BytesBuilder(copy: false);
          const flushThreshold = 512 * 1024; // 512 KB RAM buffer for silky smooth I/O

          await for (final chunk in response) {
            if (item.status == DownloadStatus.failed) {
              await output.close();
              return;
            }
            while (item.status == DownloadStatus.paused) {
              await Future.delayed(const Duration(milliseconds: 300));
            }

            buffer.add(chunk);
            item.downloadedBytes += chunk.length;
            item.progress = (item.downloadedBytes / (item.totalBytes > 0 ? item.totalBytes : 1)).clamp(0.0, 1.0);

            // Flush RAM buffer to disk in batches
            if (buffer.length >= flushThreshold) {
              output.add(buffer.takeBytes());
            }

            final now = DateTime.now();
            final diff = now.difference(lastUiUpdateTime).inMilliseconds;
            if (diff >= 300) {
              final bytesDiff = item.downloadedBytes - lastUiBytes;
              item.speedBytesPerSec = (bytesDiff / (diff / 1000.0));
              lastUiUpdateTime = now;
              lastUiBytes = item.downloadedBytes;
              notifyListeners();
            }
          }

          if (buffer.isNotEmpty) {
            output.add(buffer.takeBytes());
          }
          await output.flush();
          await output.close();

          // If loop completed cleanly and all bytes reached
          if (item.downloadedBytes >= item.totalBytes) {
            break;
          }
        } catch (err) {
          retries++;
          debugPrint("Stream chunk error (Attempt $retries/$maxRetries): $err");
          if (retries >= maxRetries) {
            rethrow;
          }
          // Exponential backoff before resuming stream range
          await Future.delayed(Duration(milliseconds: 1000 * retries));
        }
      }

      if (item.status != DownloadStatus.failed) {
        item.status = DownloadStatus.completed;
        item.progress = 1.0;
        _activeDownloads.remove(item);
        _completedDownloads.insert(0, item);
        notifyListeners();

        // Trigger Apple-style Island Toast
        triggerIslandToast("Saved to FE Player Library");

        // Notify Library Controller
        if (onDownloadComplete != null) {
          onDownloadComplete!(filePath, item.metadata.title);
        }
      }
    } catch (e) {
      item.status = DownloadStatus.failed;
      item.errorMessage = "Download interrupted: $e";
      debugPrint("Download failure: $e");
      notifyListeners();
    }
  }

  void pauseDownload(ActiveDownload item) {
    item.status = DownloadStatus.paused;
    item.speedBytesPerSec = 0;
    notifyListeners();
  }

  void resumeDownload(ActiveDownload item) {
    item.status = DownloadStatus.downloading;
    notifyListeners();
    _runDownloadWorker(item);
  }

  void cancelDownload(ActiveDownload item) {
    item.status = DownloadStatus.failed;
    _activeDownloads.remove(item);
    notifyListeners();
  }

  void triggerIslandToast(String message) {
    _toastMessage = message;
    _showToast = true;
    notifyListeners();

    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 4), () {
      _showToast = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _yt.close();
    _toastTimer?.cancel();
    super.dispose();
  }
}
