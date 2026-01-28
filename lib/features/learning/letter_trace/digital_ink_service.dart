import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart' hide Ink; // Hide Ink to avoid conflict with ML Kit Ink
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'drawing_canvas.dart';

/// Download status enum
enum DownloadStatus {
  idle,
  checkingConnectivity,
  checkingModel,
  downloading,
  completed,
  failed,
}

/// Download progress state
class DownloadProgress {
  final DownloadStatus status;
  final String message;
  final String? errorDetails;
  final double progress; // 0.0 to 1.0 (simulated)
  final String downloadedSize; // e.g., "1.2 MB / 40.0 MB"
  final bool hasInternet;
  final bool canReachGoogle;
  final bool amharicDownloaded;
  final bool englishDownloaded;

  const DownloadProgress({
    this.status = DownloadStatus.idle,
    this.message = '',
    this.errorDetails,
    this.progress = 0.0,
    this.downloadedSize = '',
    this.hasInternet = false,
    this.canReachGoogle = false,
    this.amharicDownloaded = false,
    this.englishDownloaded = false,
  });

  DownloadProgress copyWith({
    DownloadStatus? status,
    String? message,
    String? errorDetails,
    double? progress,
    String? downloadedSize,
    bool? hasInternet,
    bool? canReachGoogle,
    bool? amharicDownloaded,
    bool? englishDownloaded,
  }) {
    return DownloadProgress(
      status: status ?? this.status,
      message: message ?? this.message,
      errorDetails: errorDetails,
      progress: progress ?? this.progress,
      downloadedSize: downloadedSize ?? this.downloadedSize,
      hasInternet: hasInternet ?? this.hasInternet,
      canReachGoogle: canReachGoogle ?? this.canReachGoogle,
      amharicDownloaded: amharicDownloaded ?? this.amharicDownloaded,
      englishDownloaded: englishDownloaded ?? this.englishDownloaded,
    );
  }
}

/// Provider for download progress state
final downloadProgressProvider = StateProvider<DownloadProgress>((ref) {
  return const DownloadProgress();
});

/// Provider for the Digital Ink Service
final digitalInkServiceProvider = Provider<DigitalInkService>((ref) {
  return DigitalInkService(ref);
});

class DigitalInkService {
  final Ref _ref;
  final DigitalInkRecognizerModelManager _modelManager =
      DigitalInkRecognizerModelManager();
  
  // Track download cancellation
  bool _cancelDownload = false;

  DigitalInkService(this._ref);

  /// Cancel ongoing download
  void cancelDownload() {
    _cancelDownload = true;
  }

  /// Check if device has internet connectivity
  Future<bool> checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.isNotEmpty && !result.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      return false;
    }
  }

  /// Check if we can reach Google's servers
  Future<bool> checkGoogleReachability() async {
    try {
      // Simple DNS lookup check
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('Google reachability check error: $e');
      return false;
    }
  }

  /// Check if a model is downloaded
  Future<bool> isModelDownloaded(String languageCode) async {
    try {
      return await _modelManager.isModelDownloaded(languageCode);
    } catch (e) {
      debugPrint('Model check error: $e');
      return false;
    }
  }

  /// Check status of all required models
  Future<void> checkAllModelsStatus() async {
    final am = await isModelDownloaded('am');
    // English is OK if either 'en' or 'en-US' is there
    final en = await isModelDownloaded('en') || await isModelDownloaded('en-US');
    
    final notifier = _ref.read(downloadProgressProvider.notifier);
    notifier.state = notifier.state.copyWith(
      amharicDownloaded: am,
      englishDownloaded: en,
    );
  }

  /// Download essential models (en, am) sequentially
  /// 
  /// Downloads are persisted by the ML Kit plugin automatically. 
  Future<bool> downloadAllModels() async {
    _cancelDownload = false;
    final progressNotifier = _ref.read(downloadProgressProvider.notifier);
    
    try {
      // Initial status check
      await checkAllModelsStatus();
      
      // Step 1: Check connectivity
      progressNotifier.state = progressNotifier.state.copyWith(
        status: DownloadStatus.checkingConnectivity,
        message: 'Checking internet connection...',
        progress: 0.05,
        downloadedSize: '0.0 MB / 40.0 MB',
      );
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (_cancelDownload) return false;
      
      final hasInternet = await checkConnectivity();
      if (!hasInternet) {
        progressNotifier.state = progressNotifier.state.copyWith(
          status: DownloadStatus.failed,
          message: 'No internet connection',
          errorDetails: 'Please connect to WiFi or mobile data and try again.',
          hasInternet: false,
        );
        return false;
      }
      
      progressNotifier.state = progressNotifier.state.copyWith(
        status: DownloadStatus.checkingConnectivity,
        message: 'Internet connected ✓',
        progress: 0.1,
        hasInternet: true,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (_cancelDownload) return false;
      
      // Step 2: Check if we can reach Google
      progressNotifier.state = progressNotifier.state.copyWith(
        message: 'Checking Google servers...',
        progress: 0.15,
      );
      
      final canReachGoogle = await checkGoogleReachability();
      if (!canReachGoogle) {
        progressNotifier.state = progressNotifier.state.copyWith(
          status: DownloadStatus.failed,
          message: 'Cannot reach Google servers',
          errorDetails: 'Google\'s servers are unreachable.',
          hasInternet: true,
          canReachGoogle: false,
        );
        return false;
      }
      
      progressNotifier.state = progressNotifier.state.copyWith(
        status: DownloadStatus.checkingModel,
        message: 'Google servers reachable ✓',
        progress: 0.2,
        hasInternet: true,
        canReachGoogle: true,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Step 3: Download Amharic if needed
      if (!progressNotifier.state.amharicDownloaded) {
         final success = await _downloadSingleModel('am', startMb: 0.0, endMb: 20.0);
         if (!success) return false;
         progressNotifier.state = progressNotifier.state.copyWith(amharicDownloaded: true);
      } else {
         debugPrint("Amharic already downloaded, skipping.");
      }

      // Step 4: Download English if needed
      if (!progressNotifier.state.englishDownloaded) {
         // Try 'en' first, if fails, try 'en-US'
         bool success = await _downloadSingleModel('en', startMb: 20.0, endMb: 40.0);
         
         if (!success) {
             debugPrint("Failed 'en', trying 'en-US'...");
             // Slightly risky to reuse segments, but we just simulate progress anyway
             success = await _downloadSingleModel('en-US', startMb: 30.0, endMb: 40.0);
         }
         
         if (!success) return false;
         progressNotifier.state = progressNotifier.state.copyWith(englishDownloaded: true);
      } else {
         debugPrint("English already downloaded, skipping.");
      }

      // All done
      progressNotifier.state = progressNotifier.state.copyWith(
        status: DownloadStatus.completed,
        message: 'All models ready! ✓',
        progress: 1.0,
        downloadedSize: '40.0 MB / 40.0 MB',
      );
      return true;

    } catch (e) {
      debugPrint('Download flow error: $e');
      progressNotifier.state = progressNotifier.state.copyWith(
        status: DownloadStatus.failed,
        message: 'Download error',
        errorDetails: 'An unexpected error occurred: $e',
      );
      return false;
    }
  }

  Future<bool> _downloadSingleModel(String code, {required double startMb, required double endMb}) async {
    if (_cancelDownload) return false;
    
    final progressNotifier = _ref.read(downloadProgressProvider.notifier);
    final totalRange = endMb - startMb;
    final modelName = code.contains('am') ? 'Amharic' : 'English';
    
    progressNotifier.state = progressNotifier.state.copyWith(
        status: DownloadStatus.downloading,
        message: 'Downloading $modelName model...',
    );

    final downloadFuture = _modelManager.downloadModel(code, isWifiRequired: false);

    // Simulation
    double currentSimMb = startMb;
    bool isDownloading = true;

    final simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!isDownloading || _cancelDownload) {
          timer.cancel();
          return;
        }

        // Varied increments
        final increment = 0.1 + (Random().nextDouble() * 0.3); 
        currentSimMb += increment;
        
        // Cap at 95% of this segment
        if (currentSimMb > endMb - 1.0) {
           currentSimMb = endMb - 1.0 + (Random().nextDouble() * 0.2); 
        }

        final progress = currentSimMb / 40.0; // Global progress out of 40
        
        progressNotifier.state = progressNotifier.state.copyWith(
          status: DownloadStatus.downloading,
          message: 'Downloading $modelName model...',
          progress: progress.clamp(0.0, 0.98),
          downloadedSize: '${currentSimMb.toStringAsFixed(1)} MB / 40.0 MB',
        );
    });

    try {
        final result = await downloadFuture.timeout(
          const Duration(minutes: 3),
          onTimeout: () => throw TimeoutException('Download of $modelName timed out'),
        );
        
        isDownloading = false;
        simulationTimer.cancel();
        
        if (result && await isModelDownloaded(code)) {
           return true; 
        } else {
           throw Exception("Failed to download $modelName");
        }
    } catch (e) {
        isDownloading = false;
        simulationTimer.cancel();
        progressNotifier.state = progressNotifier.state.copyWith(
          status: DownloadStatus.failed,
          message: 'Failed to download $modelName ($code)',
          errorDetails: e.toString(),
        );
        return false;
    }
  }

  /// Delete a model to free space
  Future<bool> deleteModel(String languageCode) async {
    return await _modelManager.deleteModel(languageCode);
  }

  /// Recognize handwriting from strokes
  Future<List<String>> recognize(
    List<DrawingStroke> strokes,
    String languageCode,
  ) async {
    if (strokes.isEmpty) return [];

    String modelTag = languageCode == 'amharic' ? 'am' : 'en';
    
    // Safety check - if English, check which one is actually downloaded
    if (modelTag == 'en') {
       if (await isModelDownloaded('en')) {
         modelTag = 'en';
       } else if (await isModelDownloaded('en-US')) {
         modelTag = 'en-US';
       } else {
         debugPrint('No English model found (en or en-US) during recognize');
         return [];
       }
    } else {
      // Amharic
       if (!await isModelDownloaded(modelTag)) {
           debugPrint('Model $modelTag not found during recognize call');
           return [];
       }
    }

    final ink = Ink();
    // Convert strokes to ML Kit format
    for (final stroke in strokes) {
      final mlStroke = Stroke();
      for (final p in stroke.points) {
         mlStroke.points.add(StrokePoint(
           x: p.dx, 
           y: p.dy, 
           t: DateTime.now().millisecondsSinceEpoch,
         ));
      }
      ink.strokes.add(mlStroke);
    }

    final recognizer = DigitalInkRecognizer(languageCode: modelTag);

    try {
      final candidates = await recognizer.recognize(ink);
      recognizer.close();
      return candidates.map((c) => c.text).toList();
    } catch (e) {
      recognizer.close();
      debugPrint('Recognition error: $e');
      rethrow;
    }
  }
}
