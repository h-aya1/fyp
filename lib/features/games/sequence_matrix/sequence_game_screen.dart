import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sequence_controller.dart';
import 'tile_widget.dart';

/// Main screen for the Matrix-Based Sequence Memory Game
/// Displays a 3x3 grid where children watch and repeat sequences
class SequenceGameScreen extends StatefulWidget {
  const SequenceGameScreen({Key? key}) : super(key: key);
  
  @override
  State<SequenceGameScreen> createState() => _SequenceGameScreenState();
}

class _SequenceGameScreenState extends State<SequenceGameScreen> {
  // Game controller instance
  late SequenceController _controller;
  
  // UI state variables
  int? _currentHighlightedTile; 
  String _feedbackMessage = 'Ready?'; 
  Color _feedbackColor = Colors.blue;
  bool _isCountingDown = false;
  int _countdownValue = 3;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _feedbackColor = Theme.of(context).primaryColor;
  }
  
  @override
  void initState() {
    super.initState();
    _controller = SequenceController(gridSize: 9);
    _startNewRound();
  }
  
  /// Begins a new round with a countdown
  Future<void> _startNewRound() async {
    if (!mounted) return;
    
    setState(() {
      _isCountingDown = true;
      _countdownValue = 3;
      _feedbackMessage = 'Get Ready!';
      _feedbackColor = Theme.of(context).primaryColor;
    });

    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() {
        _countdownValue = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;
    setState(() {
      _isCountingDown = false;
      _feedbackMessage = 'Watch Carefully!';
    });
    
    _playSequence();
  }
  
  /// Plays the sequence by highlighting tiles one by one
  Future<void> _playSequence() async {
    if (!mounted) return;
    _controller.startPlayingSequence(); 
    
    for (int i = 0; i < _controller.sequence.length; i++) {
      if (!mounted) return;
      final tileIndex = _controller.sequence[i];
      
      setState(() {
        _currentHighlightedTile = tileIndex;
      });
      
      await Future.delayed(
        Duration(milliseconds: _controller.getHighlightDuration()),
      );
      
      if (!mounted) return;
      setState(() {
        _currentHighlightedTile = null;
      });
      
      if (i < _controller.sequence.length - 1) {
        await Future.delayed(
          Duration(milliseconds: _controller.getDelayDuration()),
        );
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    setState(() {
      _controller.endPlayingSequence(); 
      _feedbackMessage = 'Go Ahead!';
      final theme = Theme.of(context);
      _feedbackColor = theme.brightness == Brightness.dark ? Colors.cyanAccent : Colors.teal;
    });
  }
  
  /// Handles when child taps a tile
  void _onTileTapped(int tileIndex) {
    if (!_controller.isUserTurn) return;
    
    setState(() {
      _currentHighlightedTile = tileIndex;
    });
    
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _currentHighlightedTile = null;
        });
      }
    });
    
    final isCorrect = _controller.validateTap(tileIndex);
    
    if (isCorrect) {
      if (_controller.isSequenceComplete()) {
        _onSequenceCompleted();
      } else {
        setState(() {
          _feedbackMessage = 'Next? 🤗';
          final theme = Theme.of(context);
          _feedbackColor = theme.brightness == Brightness.dark ? Colors.yellowAccent : Colors.orange;
        });
      }
    } else {
      _onWrongTap();
    }
  }
  
  void _onSequenceCompleted() {
    if (!mounted) return;
    
    setState(() {
      _controller.isUserTurn = false;
      _feedbackMessage = 'Super Star! 🌟';
      _feedbackColor = Colors.purpleAccent;
    });
    
    _controller.advanceToNextLevel();
    
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _startNewRound();
    });
  }
  
  void _onWrongTap() {
    if (!mounted) return;
    
    setState(() {
      _controller.isUserTurn = false;
      _feedbackMessage = 'Try Once More! ❤️';
      _feedbackColor = Theme.of(context).colorScheme.error;
    });
    
    _controller.resetCurrentSequence();
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _startNewRound();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Memory Fun!'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section - Stats and Level
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatCard(
                    context, 
                    'Level', 
                    '${_controller.getCurrentLevel()}',
                    Icons.star,
                    Colors.amber,
                  ),
                  const SizedBox(width: 15),
                  _buildStatCard(
                    context, 
                    'Speed', 
                    '${((800 - _controller.getHighlightDuration()) / 50 + 1).toInt()}x',
                    Icons.speed,
                    Colors.cyan,
                  ),
                ],
              ),
            ),

            // Feedback Message
            Expanded(
              flex: 1,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      _feedbackMessage,
                      key: ValueKey(_feedbackMessage),
                      style: TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.w900,
                        color: _feedbackColor,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            
            // Grid Section
            Expanded(
              flex: 4,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Opacity(
                          opacity: _isCountingDown ? 0.3 : 1.0,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: 9,
                            itemBuilder: (context, index) {
                              return TileWidget(
                                index: index,
                                isHighlighted: _currentHighlightedTile == index,
                                onTap: () => _onTileTapped(index),
                                isEnabled: _controller.isUserTurn && !_isCountingDown,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Countdown Overlay
                    if (_isCountingDown)
                      Text(
                        '$_countdownValue',
                        style: TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                        ),
                      ).animate().scale(duration: 500.ms).fadeOut(delay: 500.ms),
                  ],
                ),
              ),
            ),
            
            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _controller.startNewGame();
                          _startNewRound();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Restart'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}
