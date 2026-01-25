import 'dart:math';

/// Controls the game logic for the sequence memory game
/// Handles sequence generation, validation, and difficulty progression
class SequenceController {
  // Game state variables
  List<int> sequence = []; // Stores the sequence of tile indices to remember
  int currentInputIndex = 0; // Tracks which position in sequence child is tapping
  bool isPlayingSequence = false; // True when showing sequence to child
  bool isUserTurn = false; // True when child can tap tiles
  
  // Base timing constants (in milliseconds)
  static const int baseHighlightDuration = 800;
  static const int minHighlightDuration = 300;
  static const int baseDelayBetweenTiles = 400;
  static const int minDelayBetweenTiles = 150;
  
  // Grid configuration
  final int gridSize; 
  final Random _random = Random();
  
  SequenceController({this.gridSize = 9});
  
  /// Calculates highlight duration based on current level
  int getHighlightDuration() {
    // Decrease by 50ms per level above 1
    final level = sequence.length;
    final reduction = (level - 1) * 50;
    return max(minHighlightDuration, baseHighlightDuration - reduction);
  }

  /// Calculates delay between tiles based on current level
  int getDelayDuration() {
    // Decrease by 30ms per level above 1
    final level = sequence.length;
    final reduction = (level - 1) * 30;
    return max(minDelayBetweenTiles, baseDelayBetweenTiles - reduction);
  }

  /// Starts a new game by generating the first sequence
  void startNewGame() {
    sequence.clear();
    currentInputIndex = 0;
    _addNextTileToSequence();
  }
  
  /// Adds one random tile to the sequence
  void _addNextTileToSequence() {
    final newTileIndex = _random.nextInt(gridSize);
    sequence.add(newTileIndex);
  }
  
  /// Checks if the child tapped the correct tile
  bool validateTap(int tappedTileIndex) {
    if (!isUserTurn) return false;
    
    if (sequence[currentInputIndex] == tappedTileIndex) {
      currentInputIndex++;
      return true; 
    }
    
    return false;
  }
  
  /// Checks if the child has completed the entire sequence
  bool isSequenceComplete() {
    return currentInputIndex >= sequence.length;
  }
  
  /// Prepares for the next round
  void advanceToNextLevel() {
    _addNextTileToSequence();
    currentInputIndex = 0;
  }
  
  /// Resets input tracking to replay the same sequence
  void resetCurrentSequence() {
    currentInputIndex = 0;
  }
  
  /// Returns the current difficulty level
  int getCurrentLevel() {
    return sequence.length;
  }
  
  /// Marks that the sequence playback has started
  void startPlayingSequence() {
    isPlayingSequence = true;
    isUserTurn = false;
  }
  
  /// Marks that the sequence playback has ended
  void endPlayingSequence() {
    isPlayingSequence = false;
    isUserTurn = true;
  }
}
