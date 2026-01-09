import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_service.dart';

/// Camera screen that handles the camera UI
/// Shows live preview, capture button, and captured image
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Initialize the camera using the camera service
  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final success = await _cameraService.initializeCamera();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (!success) {
        _hasError = true;
        _errorMessage = 'Failed to initialize camera. Please check permissions.';
      }
    });
  }

  /// Capture an image using the camera service
  Future<void> _captureImage() async {
    final imagePath = await _cameraService.captureImage();

    if (!mounted) return;

    if (imagePath != null) {
      setState(() {
        _capturedImagePath = imagePath;
      });
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture image')),
      );
    }
  }

  /// Reset and allow retaking the image
  void _retakeImage() {
    _cameraService.resetImage();
    setState(() {
      _capturedImagePath = null;
    });
  }

  @override
  void dispose() {
    // Clean up camera resources
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Capture'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  /// Build the main body based on current state
  Widget _buildBody() {
    // Show loading indicator while initializing
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera...'),
          ],
        ),
      );
    }

    // Show error message if initialization failed
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show captured image if available
    if (_capturedImagePath != null) {
      return _buildCapturedImageView();
    }

    // Show camera preview
    return _buildCameraPreview();
  }

  /// Build the camera preview with capture button
  Widget _buildCameraPreview() {
    final controller = _cameraService.controller;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: Text('Camera not available'));
    }

    return Column(
      children: [
        // Camera preview
        Expanded(
          child: CameraPreview(controller),
        ),
        // Capture button
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.black87,
          child: Center(
            child: FloatingActionButton(
              onPressed: _captureImage,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.camera_alt, size: 32),
            ),
          ),
        ),
      ],
    );
  }

  /// Build the captured image view with retake button
  Widget _buildCapturedImageView() {
    return Column(
      children: [
        // Display captured image
        Expanded(
          child: Image.file(
            File(_capturedImagePath!),
            fit: BoxFit.contain,
          ),
        ),
        // Retake button
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.black87,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _retakeImage,
                icon: const Icon(Icons.refresh),
                label: const Text('Retake'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
