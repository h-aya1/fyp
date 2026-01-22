import 'package:flutter/foundation.dart';

class EvaluationResult {
  final bool correct;
  final double confidence;
  final String feedback;

  EvaluationResult({
    required this.correct,
    required this.confidence,
    required this.feedback,
  });

  factory EvaluationResult.empty() {
    return EvaluationResult(
      correct: false,
      confidence: 0.0,
      feedback: '',
    );
  }
}
