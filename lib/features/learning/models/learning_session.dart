import '../../dashboard/models/child_model.dart';

/// Represents a single learning session for a child.
/// 
/// This is a pure Dart model that tracks the session state, progression, and accuracy.
/// It is designed to be testable and independent of any UI framework.
class LearningSession {
  final String sessionId;
  final Child child;
  final String learningMode;
  
  String targetCharacter;
  int questionIndex;
  int correctCount;
  int attemptCount;
  final DateTime startedAt;

  LearningSession({
    required this.sessionId,
    required this.child,
    required this.learningMode,
    required this.targetCharacter,
    this.questionIndex = 0,
    this.correctCount = 0,
    this.attemptCount = 0,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  /// Registers an attempt for the current target character.
  /// 
  /// Increments [attemptCount] and [correctCount] if [correct] is true.
  void registerAttempt({required bool correct}) {
    attemptCount++;
    if (correct) {
      correctCount++;
    }
  }

  /// Calculates the accuracy of the session as a percentage (0.0 to 1.0).
  double get accuracy => attemptCount == 0 ? 0.0 : correctCount / attemptCount;

  /// Returns true if the session is considered completed.
  /// 
  /// In the current implementation, sessions are open-ended, but this
  /// can be extended to support fixed-length sessions (e.g. 10 questions).
  bool get isCompleted => false;

  /// Creates a copy of the session with optional field updates.
  LearningSession copyWith({
    String? targetCharacter,
    int? questionIndex,
    int? correctCount,
    int? attemptCount,
  }) {
    return LearningSession(
      sessionId: sessionId,
      child: child,
      learningMode: learningMode,
      targetCharacter: targetCharacter ?? this.targetCharacter,
      questionIndex: questionIndex ?? this.questionIndex,
      correctCount: correctCount ?? this.correctCount,
      attemptCount: attemptCount ?? this.attemptCount,
      startedAt: startedAt,
    );
  }
}
