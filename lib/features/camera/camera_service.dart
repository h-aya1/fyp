import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// Service class that handles all camera-related logic
/// Separates camera business logic from UI
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  String? _imagePath;

  /// Get the camera controller
  CameraController? get controller => _controller;

  /// Get the path of the last captured image
  String? get imagePath => _imagePath;

  /// Initialize the camera
  /// Returns true if successful, false otherwise
  Future<bool> initializeCamera() async {
    try {
      // Get list of available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        return false;
      }

      // Use the first available camera (usually back camera)
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      // Initialize the controller
      await _controller!.initialize();
      return true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      return false;
    }
  }

  /// Capture an image and return the file path
  /// Returns null if capture fails
  Future<String?> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      // Capture the image
      final XFile image = await _controller!.takePicture();
      _imagePath = image.path;
      return _imagePath;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  /// Reset the captured image (for retaking)
  void resetImage() {
    _imagePath = null;
  }

  /// Dispose of camera resources
  /// MUST be called when done using the camera
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
