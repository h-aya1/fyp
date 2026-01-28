import 'package:uuid/uuid.dart';

/// Represents a single handwriting attempt by a child.
/// 
/// This model captures the AI evaluation results and is saved locally first,
/// then synced to Supabase when online. The learning flow never blocks on network.
/// 
/// Phase 1: No authentication - attempts are linked to children via UUID only.
class HandwritingAttempt {
  /// Unique identifier (UUID) generated client-side
  final String id;

  /// Foreign key to the child who made this attempt
  final String childId;

  /// The character the child was attempting to write
  final String targetCharacter;

  /// AI-evaluated shape similarity: "high", "medium", or "low"
  final String shapeSimilarity;

  /// Confidence score from AI evaluation (0.0 to 1.0)
  final double confidenceScore;

  /// Feedback text from AI evaluation
  final String feedbackText;

  /// Timestamp when the attempt was made
  final DateTime createdAt;

  HandwritingAttempt({
    String? id,
    required this.childId,
    required this.targetCharacter,
    required this.shapeSimilarity,
    required this.confidenceScore,
    required this.feedbackText,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Determines if this attempt was successful (high similarity)
  bool get isSuccessful => shapeSimilarity == 'high';

  /// Creates a copy with optional field updates
  HandwritingAttempt copyWith({
    String? id,
    String? childId,
    String? targetCharacter,
    String? shapeSimilarity,
    double? confidenceScore,
    String? feedbackText,
    DateTime? createdAt,
  }) {
    return HandwritingAttempt(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      targetCharacter: targetCharacter ?? this.targetCharacter,
      shapeSimilarity: shapeSimilarity ?? this.shapeSimilarity,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      feedbackText: feedbackText ?? this.feedbackText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON for SQLite storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'child_id': childId,
        'target_character': targetCharacter,
        'shape_similarity': shapeSimilarity,
        'confidence_score': confidenceScore,
        'feedback_text': feedbackText,
        'created_at': createdAt.toIso8601String(),
      };

  /// Create from JSON (SQLite or Supabase)
  factory HandwritingAttempt.fromJson(Map<String, dynamic> json) {
    return HandwritingAttempt(
      id: json['id'] as String,
      childId: json['child_id'] as String,
      targetCharacter: json['target_character'] as String,
      shapeSimilarity: json['shape_similarity'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      feedbackText: json['feedback_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  String toString() =>
      'HandwritingAttempt(id: $id, childId: $childId, targetCharacter: $targetCharacter, similarity: $shapeSimilarity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HandwritingAttempt &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
