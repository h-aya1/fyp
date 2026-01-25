import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class BubbleWidget extends StatefulWidget {
  final String letter;
  final Color color;
  final bool Function(String) onCheck; 
  final VoidCallback onAnimationComplete; 

  const BubbleWidget({
    super.key,
    required this.letter,
    required this.color,
    required this.onCheck,
    required this.onAnimationComplete,
  });

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget> {
  bool _isPopped = false;
  late final double _randomWait;
  
  @override
  void initState() {
    super.initState();
    _randomWait = Random().nextDouble() * 2;
  }

  void _handleTap() async {
    if (_isPopped) return;
    
    bool isCorrect = widget.onCheck(widget.letter);
    
    if (isCorrect) {
      setState(() => _isPopped = true);
      // Wait for burst animation to complete
      await Future.delayed(const Duration(milliseconds: 400));
      widget.onAnimationComplete();
    } else {
      // Small "oops" shake is handled by flutter_animate if we had it, 
      // but let's just use a simple state-triggered shake.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPopped) {
      return _buildBurstEffect();
    }

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              widget.color.withOpacity(0.3),
              widget.color.withOpacity(0.6),
              widget.color,
            ],
            stops: const [0.5, 0.8, 1.0],
            center: const Alignment(-0.3, -0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
            // "Reflection" highlight
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 2,
              offset: const Offset(-20, -20),
              spreadRadius: -30,
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            widget.letter,
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      )
      .animate(onPlay: (controller) => controller.repeat(reverse: true))
      .moveY(
        begin: -10, 
        end: 10, 
        duration: 2000.ms, 
        curve: Curves.easeInOut,
        delay: Duration(seconds: _randomWait.toInt()),
      )
      .animate()
      .scale(
        begin: const Offset(0, 0), 
        end: const Offset(1, 1), 
        duration: 600.ms, 
        curve: Curves.elasticOut
      ),
    );
  }

  Widget _buildBurstEffect() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(8, (index) {
          final angle = (index * 45) * pi / 180;
          return Positioned(
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            )
            .animate()
            .move(
              begin: Offset.zero,
              end: Offset(cos(angle) * 60, sin(angle) * 60),
              duration: 400.ms,
              curve: Curves.easeOutCirc,
            )
            .scale(begin: const Offset(1, 1), end: const Offset(0, 0), duration: 400.ms)
            .fadeOut(duration: 400.ms),
          );
        }),
      ),
    );
  }
}
