
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CameraScreen extends StatefulWidget {
  final Function(XFile) onCaptured;
  const CameraScreen({super.key, required this.onCaptured});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    _startCamera(_selectedCameraIndex);
  }

  Future<void> _startCamera(int index) async {
    if (_controller != null) {
      await _controller!.dispose();
    }
    _controller = CameraController(
      _cameras[index], 
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _startCamera(_selectedCameraIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CameraPreview(_controller!),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(LucideIcons.refreshCcw, color: Colors.white, size: 32),
              onPressed: _switchCamera,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: () async {
                final file = await _controller!.takePicture();
                widget.onCaptured(file);
              },
              child: const Icon(LucideIcons.camera, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
