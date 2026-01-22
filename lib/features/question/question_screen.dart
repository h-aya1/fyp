import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../learning/controllers/handwriting_controller.dart';
import '../../core/constants.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  final String category;
  const QuestionScreen({super.key, required this.category});

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  CameraController? _controller;
  String _currentChar = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
    _pickNextCharacter();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first);
    _controller = CameraController(back, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  void _pickNextCharacter() {
    final pool = _getPoolForCategory();
    final state = ref.read(appStateProvider); // Bridge to your AppState

    // Adaptive weighting
    final masteryMap = {
      for (var m in state.selectedChild?.mastery ?? []) m.character: m
    };

    final candidates = pool.map((char) {
      final record = masteryMap[char];
      double weight = 10.0;
      if (record != null) weight = (1.0 - record.successRate) * 20.0 + 1.0;
      return MapEntry(char, weight);
    }).toList();

    double totalWeight =
        candidates.fold(0, (sum, item) => sum + item.value.toDouble());
    double randVal = (totalWeight * (DateTime.now().millisecond / 1000)) %
        totalWeight; // quick random-like

    String selected = pool.first;
    for (var item in candidates) {
      randVal -= item.value;
      if (randVal <= 0) {
        selected = item.key;
        break;
      }
    }

    setState(() => _currentChar = selected);
  }

  List<String> _getPoolForCategory() {
    switch (widget.category) {
      case 'ENGLISH':
        return AppConstants.englishAlphabet;
      case 'NUMBERS':
        return AppConstants.numbers;
      case 'AMHARIC':
        return AppConstants.amharicAlphabet;
      default:
        return [
          ...AppConstants.englishAlphabet,
          ...AppConstants.numbers,
          ...AppConstants.amharicAlphabet
        ];
    }
  }

  Future<void> _handleCapture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();

      // ⚡ Use Riverpod HandwritingController
      final controller = ref.read(handwritingControllerProvider.notifier);
      await controller.checkHandwriting(bytes, _currentChar);

      final state = ref.read(handwritingControllerProvider);

      if (!mounted) return;

      _showResultOverlay(
        state.isCorrect ?? false,
        state.result?['description'] ?? "Let's try again!",
      );
    } catch (e) {
      debugPrint('Error capturing or analyzing: $e');
    }
  }

  void _showResultOverlay(bool correct, String feedback) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              correct ? Icons.check_circle : Icons.error,
              size: 80,
              color: correct ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              correct ? "Great Job!" : "Try Again!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(feedback, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _pickNextCharacter();
              },
              child: const Text("Next One!"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(handwritingControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Writing Time!')),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  _currentChar,
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const Text(
                'Write this and show the camera!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.blue, width: 4),
                      color: Colors.black,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _controller != null && _controller!.value.isInitialized
                        ? CameraPreview(_controller!)
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: FloatingActionButton.large(
                  onPressed: _handleCapture,
                  child: aiState.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.camera_alt),
                ),
              ),
            ],
          ),

          // ⚡ Overlay for AI checking
          if (aiState.loading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 6),
              ),
            ),
        ],
      ),
    );
  }
}
