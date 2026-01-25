import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/audio_service.dart';

enum GamePhase {
  menu,        // Select mode
  prompt,      // "Pop the A"
  playing,     // Bubbles appearing/popping
  result       // "Good job!"
}

enum GameMode {
  stream, // One by one (Fast)
  search  // Multiple at once (Find target)
}

class PhonicsBubbleController {
  // Game State
  String targetLetter = '';
  List<String> activeBubbles = [];
  int correctPopsDisplay = 0;
  GamePhase currentPhase = GamePhase.menu;
  GameMode currentGameMode = GameMode.search;
  
  // Internal State
  int _targetPopsInRound = 5;
  int _currentPopsInRound = 0;
  
  Timer? _bubbleTimer; 
  Timer? _spawnerTimer;
  
  final Random _random = Random();
  
  final List<String> _englishLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'M', 'S', 'P', 'T'];
  final List<String> _amharicLetters = ['ሀ', 'ለ', 'ሐ', 'መ', 'ሠ', 'ረ', 'ሰ', 'ሸ', 'ቀ', 'በ'];
  
  final VoidCallback onStateChanged;
  
  PhonicsBubbleController({required this.onStateChanged});

  void dispose() {
    _bubbleTimer?.cancel();
    _spawnerTimer?.cancel();
  }

  void initGame() {
    // Show menu first
    currentPhase = GamePhase.menu;
    onStateChanged();
  }
  
  void startGame(GameMode mode) {
    currentGameMode = mode;
    _currentPopsInRound = 0;
    correctPopsDisplay = 0;
    _startNewRound();
  }

  void _startNewRound() {
    _currentPopsInRound = 0;
    _generateTarget();
    _startPromptPhase();
  }

  void _generateTarget() {
    bool useEnglish = _random.nextBool();
    List<String> pool = useEnglish ? _englishLetters : _amharicLetters;
    targetLetter = pool[_random.nextInt(pool.length)];
  }

  Future<void> _startPromptPhase() async {
    currentPhase = GamePhase.prompt;
    activeBubbles.clear();
    onStateChanged();
    
    // Speak Prompt
    await audioService.speak("Pop the $targetLetter");
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    currentPhase = GamePhase.playing;
    
    if (currentGameMode == GameMode.search) {
      _spawnSearchLevel();
    } else {
      _spawnNextBubbleStream();
    }
  }

  // --- Search Mode Logic ---
  void _spawnSearchLevel() {
    // 3 to 5 bubbles
    int count = 3 + _random.nextInt(3);
    activeBubbles = [targetLetter];
    
    // Distractors
    List<String> pool = _englishLetters.contains(targetLetter) ? _englishLetters : _amharicLetters;
    
    while (activeBubbles.length < count) {
      String dist = pool[_random.nextInt(pool.length)];
      if (!activeBubbles.contains(dist)) { // Ensure unique visual letters
        activeBubbles.add(dist);
      }
    }
    
    activeBubbles.shuffle();
    onStateChanged();
    
    // No timer for "Search" mode? Or generous one?
    // Let's rely on user speed. No strict timeout.
  }

  // --- Stream Mode Logic ---
  void _spawnNextBubbleStream() {
    if (currentPhase != GamePhase.playing) return;
    
    if (_currentPopsInRound >= _targetPopsInRound) {
      _endRound();
      return;
    }

    bool isTarget = _random.nextBool();
    String letter = isTarget ? targetLetter : _getDistractor();
    
    activeBubbles = [letter];
    onStateChanged();
    
    _startBubbleTimerStream(letter);
  }
  
  String _getDistractor() {
     List<String> pool = _englishLetters.contains(targetLetter) ? _englishLetters : _amharicLetters;
     String dist;
     do {
       dist = pool[_random.nextInt(pool.length)];
     } while (dist == targetLetter);
     return dist;
  }

  void _startBubbleTimerStream(String letter) {
    _bubbleTimer?.cancel();
    
    // Decrease duration as level increases (base 2000ms, min 800ms)
    final baseDuration = 2000;
    final reduction = min(1200, correctPopsDisplay * 100);
    final duration = max(800, baseDuration - reduction);
    
    _bubbleTimer = Timer(Duration(milliseconds: duration), () {
      _handleTimeoutStream(letter);
    });
  }

  void _handleTimeoutStream(String letter) {
    if (!activeBubbles.contains(letter)) return;
    removeBubble(letter, isPopped: false);
  }

  // --- Interaction ---
  bool handleTap(String letter) {
    if (currentPhase != GamePhase.playing) return false;
    
    if (letter == targetLetter) {
      _bubbleTimer?.cancel();
      audioService.playSuccess();
      
      _currentPopsInRound++;
      correctPopsDisplay++;
      
      return true; 
    } else {
      audioService.playError();
      audioService.speak("Try again!");
      return false;
    }
  }

  void removeBubble(String letter, {bool isPopped = true}) {
    if (activeBubbles.contains(letter)) {
       activeBubbles.remove(letter);
       onStateChanged();
       
       if (currentGameMode == GameMode.stream) {
          _spawnerTimer = Timer(const Duration(milliseconds: 200), _spawnNextBubbleStream);
       } else {
          if (isPopped && letter == targetLetter) {
             if (_currentPopsInRound >= _targetPopsInRound) {
                 _endRound();
             } else {
                 _spawnerTimer = Timer(const Duration(milliseconds: 400), () {
                    _spawnSearchLevel(); 
                 });
             }
          }
       }
    }
  }
  
  Future<void> _endRound() async {
    currentPhase = GamePhase.result;
    activeBubbles.clear();
    onStateChanged();
    
    audioService.playSuccess();
    await audioService.speak("Well done! Ready for more?");
    
    await Future.delayed(const Duration(seconds: 2));
    _startNewRound(); // Continue to next round with same target or new? 
    // Usually better to go back to menu to avoid infinite loop without choice, 
    // but the user asked for "progressive", so let's continue with a NEW target.
  }
}
