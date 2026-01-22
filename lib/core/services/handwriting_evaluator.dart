import '../models/evaluation_result.dart';

class HandwritingEvaluator {
  EvaluationResult evaluate(Map<String, dynamic> perception, String targetChar) {
    final similarity = perception['shape_similarity'] as String? ?? 'low';
    final description = perception['description'] as String? ?? 'No description provided.';
    
    // Simple deterministic rule for correctness
    final bool correct = similarity.toLowerCase() == 'high';
    
    // Confidence mapping (example logic)
    double confidence = 0.5;
    if (similarity == 'high') confidence = 0.9;
    if (similarity == 'medium') confidence = 0.6;
    if (similarity == 'low') confidence = 0.2;

    return EvaluationResult(
      correct: correct,
      confidence: confidence,
      feedback: description,
    );
  }
}
