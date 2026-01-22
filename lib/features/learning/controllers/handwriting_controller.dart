import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/handwriting_ai_service.dart';
import '../models/handwriting_ai_state.dart';

final handwritingControllerProvider =
    StateNotifierProvider<HandwritingController, HandwritingState>(
        (ref) => HandwritingController(ref));

class HandwritingController extends StateNotifier<HandwritingState> {
  final Ref _ref;

  HandwritingController(this._ref) : super(const HandwritingState.idle());

  Future<void> analyze(Uint8List imageBytes, String targetChar) async {
    await checkHandwriting(imageBytes, targetChar);
  }

  Future<void> checkHandwriting(Uint8List imageBytes, String targetChar) async {
    state = const HandwritingState.loading();

    final service = _ref.read(handwritingAIServiceProvider);
    try {
      final result = await service.analyzeHandwriting(imageBytes, targetChar);
      final isCorrect = result['shape_similarity'] == 'high';
      state = HandwritingState.success(result, isCorrect);
    } catch (e) {
      state = HandwritingState.error('AI analysis failed. Please try again.');
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
