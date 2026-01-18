import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/learning_session.dart';
import '../../dashboard/models/child_model.dart';
import '../../camera/camera_service.dart';
import '../../../core/constants.dart';
import '../../../core/audio_service.dart';

/// Controller that manages a [LearningSession].
/// 
/// It handles character selection logic, interacts with [CameraService] for validation,
/// and updates mastery data via the provided callback.
class LearningSessionController extends ChangeNotifier {
  LearningSession? _session;
  final CameraService _cameraService = CameraService();
  final Function(String, bool) onUpdateMastery;

  bool _isProcessing = false;

  LearningSession? get session => _session;
  bool get isProcessing => _isProcessing;

  LearningSessionController({required this.onUpdateMastery});

  /// Starts a new learning session for the given [child] and [mode].
  void startSession(Child child, String mode) {
    final initialChar = _pickNextCharacter(child, mode);
    _session = LearningSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      child: child,
      learningMode: mode,
      targetCharacter: initialChar,
    );
    
    // Announce the first character
    audioService.speak(initialChar);
    notifyListeners();
  }

  /// Submits handwriting bytes for validation against the current target character.
  Future<Map<String, dynamic>> submitHandwritingResult(Uint8List imageBytes) async {
    if (_session == null) throw Exception('No active session');

    _isProcessing = true;
    notifyListeners();

    try {
      final result = await _cameraService.validateHandwriting(imageBytes, _session!.targetCharacter);
      final isCorrect = result['correct'] as bool;

      // Update session metrics
      _session!.registerAttempt(correct: isCorrect);
      
      // Update mastery via the provided callback (AppState.updateMastery)
      onUpdateMastery(_session!.targetCharacter, isCorrect);

      _isProcessing = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Advances to the next question by picking a new target character.
  void advanceQuestion() {
    if (_session == null) return;

    final nextChar = _pickNextCharacter(_session!.child, _session!.learningMode);
    _session = _session!.copyWith(
      targetCharacter: nextChar,
      questionIndex: _session!.questionIndex + 1,
    );
    
    // Announce the next character
    audioService.speak(nextChar);
    notifyListeners();
  }

  /// Logic for picking the next character based on weight and mastery.
  /// Moved from QuestionScreen for better architectural separation.
  String _pickNextCharacter(Child child, String mode) {
    final List<String> pool;
    switch (mode) {
      case 'ENGLISH': pool = AppConstants.englishAlphabet; break;
      case 'NUMBERS': pool = AppConstants.numbers; break;
      case 'AMHARIC': pool = AppConstants.amharicAlphabet; break;
      default: pool = [...AppConstants.englishAlphabet, ...AppConstants.numbers, ...AppConstants.amharicAlphabet];
    }

    final mastery = {for (var m in child.mastery) m.character: m};
    
    double totalWeight = 0;
    List<MapEntry<String, double>> candidates = pool.map((c) {
      final m = mastery[c];
      // Higher weight for characters the child struggles with or hasn't tried.
      double w = m == null ? 10.0 : (1.0 - m.successRate) * 20.0 + 1.0;
      totalWeight += w;
      return MapEntry(c, w);
    }).toList();

    double randomVal = Random().nextDouble() * totalWeight;
    for (var item in candidates) {
      randomVal -= item.value;
      if (randomVal <= 0) {
        return item.key;
      }
    }
    return pool.isNotEmpty ? pool[Random().nextInt(pool.length)] : '?';
  }

  /// Ends the current session.
  void endSession() {
    _session = null;
    notifyListeners();
  }
}
