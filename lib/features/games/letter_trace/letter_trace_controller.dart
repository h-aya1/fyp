import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyp/features/games/letter_trace/drawing_canvas.dart';
import 'digital_ink_service.dart';
import 'letter_data.dart';

/// Language mode for the game
enum LetterLanguage { english, amharic }

/// Game phase
enum LetterTracePhase { menu, downloading, playing, evaluating, result }

/// Result of letter evaluation
enum EvaluationResult { correct, incorrect, pending }

/// State class for the letter trace game
class LetterTraceState {
  final LetterTracePhase phase;
  final LetterLanguage language;
  final LetterData? currentLetter;
  final List<String> completedLetters;
  final int score;
  final int streak;
  final int totalAttempts;
  final int correctAnswers;
  final int incorrectAnswers;
  final EvaluationResult lastResult;
  final String? feedbackMessage;
  final bool isLoading;
  final String? error;
  final List<String> debugCandidates; // For detailed checking if needed

  const LetterTraceState({
    this.phase = LetterTracePhase.menu,
    this.language = LetterLanguage.english,
    this.currentLetter,
    this.completedLetters = const [],
    this.score = 0,
    this.streak = 0,
    this.totalAttempts = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.lastResult = EvaluationResult.pending,
    this.feedbackMessage,
    this.isLoading = false,
    this.error,
    this.debugCandidates = const [],
  });

  LetterTraceState copyWith({
    LetterTracePhase? phase,
    LetterLanguage? language,
    LetterData? currentLetter,
    List<String>? completedLetters,
    int? score,
    int? streak,
    int? totalAttempts,
    int? correctAnswers,
    int? incorrectAnswers,
    EvaluationResult? lastResult,
    String? feedbackMessage,
    bool? isLoading,
    String? error,
    List<String>? debugCandidates,
  }) {
    return LetterTraceState(
      phase: phase ?? this.phase,
      language: language ?? this.language,
      currentLetter: currentLetter ?? this.currentLetter,
      completedLetters: completedLetters ?? this.completedLetters,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      lastResult: lastResult ?? this.lastResult,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      debugCandidates: debugCandidates ?? this.debugCandidates,
    );
  }
}

/// Controller for the letter trace game
class LetterTraceController extends StateNotifier<LetterTraceState> {
  final Ref _ref;
  final Random _random = Random();
  
  LetterTraceController(this._ref) : super(const LetterTraceState());

  /// Start the game with selected language
  Future<void> startGame(LetterLanguage language) async {
    // Check if model needs downloading first
    final service = _ref.read(digitalInkServiceProvider);
    
    // Always check for both models now, as per user requirement to handle global offline state
    final am = await service.isModelDownloaded('am'); 
    final en = await service.isModelDownloaded('en');
    
    if (!am || !en) {
       state = LetterTraceState(
          phase: LetterTracePhase.downloading,
          language: language,
          isLoading: true,
       );
       
       // Use downloadAllModels for multiple model support
       final success = await service.downloadAllModels();
       if (!success) {
         state = state.copyWith(
           phase: LetterTracePhase.menu,
           isLoading: false,
           error: "Download failed. Check the error details and try again.",
         );
         return;
       }
    }

    state = LetterTraceState(
      phase: LetterTracePhase.playing,
      language: language,
      completedLetters: [],
      score: 0,
      streak: 0,
      totalAttempts: 0,
    );
    _selectNextLetter();
  }

  /// Reset to menu
  void goToMenu() {
    state = const LetterTraceState(phase: LetterTracePhase.menu);
  }

  /// Select the next letter
  void _selectNextLetter() {
    final letters = state.language == LetterLanguage.amharic
        ? getAllAmharicLetters()
        : getAllEnglishLetters();
    
    // Filter out completed letters
    final recentlyCompleted = state.completedLetters.length > 10
        ? state.completedLetters.sublist(state.completedLetters.length - 10)
        : state.completedLetters;
    
    final available = letters.where(
      (l) => !recentlyCompleted.contains(l.letter)
    ).toList();
    
    final letterList = available.isEmpty ? letters : available;
    final nextLetter = letterList[_random.nextInt(letterList.length)];
    
    state = state.copyWith(
      currentLetter: nextLetter,
      lastResult: EvaluationResult.pending,
      feedbackMessage: null,
      error: null,
      debugCandidates: [],
    );
  }

  /// Skip to next letter without evaluation
  void skipLetter() {
    _selectNextLetter();
  }

  /// Evaluate the drawn letter
  /// [strokes] - The list of DrawingStroke from the canvas
  Future<void> evaluateStrokes(List<DrawingStroke> strokes) async {
    if (state.currentLetter == null) return;
    
    state = state.copyWith(
      phase: LetterTracePhase.evaluating,
      isLoading: true,
      error: null,
    );

    try {
      final service = _ref.read(digitalInkServiceProvider);
      // Determine language code ('am' or 'en') based on current mode
      final langCode = state.language == LetterLanguage.amharic ? 'amharic' : 'english';
      
      final candidates = await service.recognize(strokes, langCode);
      
      // Check if target letter is in the top candidates
      // We check top 3 candidates for forgiveness in drawing style
      final target = state.currentLetter!.letter;
      bool isCorrect = false;
      
      // Direct match
      if (candidates.contains(target)) {
        isCorrect = true;
      } 
      // Case insensitive match for English
      else if (state.language == LetterLanguage.english) {
         isCorrect = candidates.any((c) => c.toLowerCase() == target.toLowerCase());
      }
      
      // Some visual similarity forgiveness could be added here if needed
      
      if (isCorrect) {
        state = state.copyWith(
          phase: LetterTracePhase.result,
          lastResult: EvaluationResult.correct,
          score: state.score + 1,
          streak: state.streak + 1,
          totalAttempts: state.totalAttempts + 1,
          correctAnswers: state.correctAnswers + 1,
          completedLetters: [...state.completedLetters, target],
          feedbackMessage: _getSuccessMessage(),
          isLoading: false,
          debugCandidates: candidates,
        );
      } else {
        state = state.copyWith(
          phase: LetterTracePhase.result,
          lastResult: EvaluationResult.incorrect,
          streak: 0,
          totalAttempts: state.totalAttempts + 1,
          incorrectAnswers: state.incorrectAnswers + 1,
          feedbackMessage: _getEncouragementMessage(),
          isLoading: false,
          debugCandidates: candidates,
        );
      }
    } catch (e) {
      state = state.copyWith(
        phase: LetterTracePhase.playing,
        isLoading: false,
        error: 'Offline recognition failed. Try restarting the game.',
      );
    }
  }

  /// Move to next letter after result
  void nextLetter() {
    state = state.copyWith(
      phase: LetterTracePhase.playing,
      lastResult: EvaluationResult.pending,
      feedbackMessage: null,
    );
    _selectNextLetter();
  }

  /// Retry the current letter
  void retryLetter() {
    state = state.copyWith(
      phase: LetterTracePhase.playing,
      lastResult: EvaluationResult.pending,
      feedbackMessage: null,
    );
  }

  /// Change language mid-game
  void changeLanguage(LetterLanguage language) {
    if (state.language != language) {
      // Trigger start game again to ensure model is downloaded
      startGame(language);
    }
  }

  String _getSuccessMessage() {
    final messages = [
      'Excellent work! 🌟',
      'Perfect! ⭐',
      'Amazing! 🎉',
      'Great job! 👏',
      'Wonderful! 💫',
      'You did it! 🏆',
      'Super! 🚀',
      'Fantastic! ✨',
    ];
    return messages[_random.nextInt(messages.length)];
  }

  String _getEncouragementMessage() {
    final messages = [
      "Almost there! Try again! 💪",
      "Good effort! Let's try once more! 🌈",
      "Make sure to close your shapes! 🌟",
      "Nice try! One more time! 🎯",
      "You're learning! Try again! 📝",
    ];
    return messages[_random.nextInt(messages.length)];
  }
}

/// Provider for the letter trace controller
final letterTraceControllerProvider =
    StateNotifierProvider<LetterTraceController, LetterTraceState>(
  (ref) => LetterTraceController(ref),
);
