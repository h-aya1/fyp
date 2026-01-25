import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A single animated tile in the sequence grid
/// Changes appearance when highlighted during sequence playback or when tapped
class TileWidget extends StatelessWidget {
  final int index; // Position in the grid (0-8 for 3x3)
  final bool isHighlighted; // True when this tile should light up
  final VoidCallback onTap; // Function to call when child taps this tile
  final bool isEnabled; // False during sequence playback (no tapping allowed)
  
  const TileWidget({
    Key? key,
    required this.index,
    required this.isHighlighted,
    required this.onTap,
    required this.isEnabled,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Define colors for normal and highlighted states
    final Color normalColor = isDark 
        ? colorScheme.surfaceContainerHighest.withOpacity(0.4) 
        : Colors.white; 
    
    // Vibrant colors for highlights (kids love bright colors)
    final List<Color> highlightGradients = isDark 
        ? [colorScheme.secondary, colorScheme.primary] 
        : [colorScheme.tertiary, colorScheme.secondary];
    
    final Color borderColor = isDark 
        ? colorScheme.outline.withOpacity(0.1) 
        : colorScheme.outlineVariant.withOpacity(0.5);
    
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.elasticOut,
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isHighlighted ? null : normalColor,
          gradient: isHighlighted ? LinearGradient(
            colors: highlightGradients,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(
            color: isHighlighted ? Colors.transparent : borderColor,
            width: 2.0,
          ),
          boxShadow: isHighlighted ? [
            BoxShadow(
              color: highlightGradients[0].withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            )
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 38.0,
              fontWeight: FontWeight.w900,
              color: isHighlighted 
                  ? Colors.white 
                  : (isDark ? colorScheme.onSurface : colorScheme.onSurfaceVariant),
              shadows: isHighlighted ? [
                const Shadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ] : null,
            ),
          ).animate(target: isHighlighted ? 1 : 0)
           .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 250.ms, curve: Curves.easeOutBack)
           .shimmer(duration: 800.ms, color: Colors.white30),
        ),
      ).animate(target: isHighlighted ? 1 : 0)
       .move(begin: const Offset(0, 0), end: const Offset(0, -6), duration: 250.ms, curve: Curves.easeOutBack),
    );
  }
}
