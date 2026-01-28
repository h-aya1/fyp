import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/handwriting_ai_service.dart';
import '../../../core/services/persistence_service.dart';
import '../../../core/models/handwriting_attempt.dart';
import '../models/handwriting_ai_state.dart';

final handwritingControllerProvider =
    StateNotifierProvider<HandwritingController, HandwritingState>(
        (ref) => HandwritingController(ref));

class HandwritingController extends StateNotifier<HandwritingState> {
  final Ref _ref;
  final PersistenceService _persistence = PersistenceService();

  HandwritingController(this._ref) : super(const HandwritingState.idle());

  /// Analyze handwriting and save attempt to local database
  /// 
  /// Phase 1: This method never blocks on network. AI evaluation and saving
  /// happen locally first, then sync to cloud happens in background.
  Future<void> analyze(
    Uint8List imageBytes,
    String targetChar, {
    String? childId,
  }) async {
    await checkHandwriting(imageBytes, targetChar, childId: childId);
  }

  Future<void> checkHandwriting(
    Uint8List imageBytes,
    String targetChar, {
    String? childId,
  }) async {
    state = const HandwritingState.loading();

    final service = _ref.read(handwritingAIServiceProvider);
    try {
      // 1. Get AI evaluation (from FastAPI or mock)
      final result = await service.analyzeHandwriting(imageBytes, targetChar);
      final isCorrect = result['shape_similarity'] == 'high';

      // 2. Save attempt to local database (if childId provided)
      if (childId != null) {
        final attempt = HandwritingAttempt(
          childId: childId,
          targetCharacter: targetChar,
          shapeSimilarity: result['shape_similarity'] as String,
          confidenceScore: _calculateConfidence(result['shape_similarity'] as String),
          feedbackText: result['description'] as String,
        );

        // Save locally first (never blocks on network)
        await _persistence.saveHandwritingAttempt(attempt);
        debugPrint('✅ Handwriting attempt saved locally');
      } else {
        debugPrint('⚠️ No childId provided, attempt not saved');
      }

      // 3. Update UI state
      state = HandwritingState.success(result, isCorrect);
    } catch (e) {
      debugPrint('❌ Handwriting analysis failed: $e');
      state = HandwritingState.error('AI analysis failed. Please try again.');
    }
  }

  /// Calculate confidence score from similarity level
  double _calculateConfidence(String similarity) {
    switch (similarity.toLowerCase()) {
      case 'high':
        return 0.9;
      case 'medium':
        return 0.6;
      case 'low':
        return 0.3;
      default:
        return 0.5;
    }
  }

  void reset() {
    state = const HandwritingState.idle();
  }
}

/// States for the controller
class HandwritingState {
  final bool loading;
  final bool? isCorrect;
  final Map<String, dynamic>? result;
  final String? error;

  const HandwritingState._(
      {this.loading = false, this.isCorrect, this.result, this.error});

  const HandwritingState.idle() : this._();
  const HandwritingState.loading() : this._(loading: true);
  const HandwritingState.success(Map<String, dynamic> result, bool isCorrect)
      : this._(loading: false, result: result, isCorrect: isCorrect);
  const HandwritingState.error(String message)
      : this._(loading: false, error: message);
}
