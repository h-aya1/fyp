import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../letter_trace/digital_ink_service.dart';
import '../letter_trace/drawing_canvas.dart';
import '../letter_trace/download_model_dialog.dart';
import '../../../core/audio_service.dart';

class WritingInputArea extends ConsumerStatefulWidget {
  final String targetChar;
  final String languageMode; // 'AMHARIC' or 'ENGLISH'
  final Function(bool isCorrect) onResult;
  final VoidCallback onNext; // Callback when user clicks 'Next Answer'

  const WritingInputArea({
    super.key,
    required this.targetChar,
    required this.languageMode,
    required this.onResult,
    required this.onNext,
  });

  @override
  ConsumerState<WritingInputArea> createState() => _WritingInputAreaState();
}

class _WritingInputAreaState extends ConsumerState<WritingInputArea> {
  final GlobalKey<DrawingCanvasState> _drawingCanvasKey = GlobalKey<DrawingCanvasState>();
  bool _isLoading = false;
  
  // Game State
  bool _showResult = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkModelAvailability();
    });
  }

  @override
  void didUpdateWidget(WritingInputArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageMode != widget.languageMode) {
      _checkModelAvailability();
    }
    // Reset state if target char changes
    if (oldWidget.targetChar != widget.targetChar) {
      setState(() {
         _showResult = false;
         _isCorrect = false;
         _isLoading = false;
      });
      _drawingCanvasKey.currentState?.clear();
    }
  }

  Future<void> _checkModelAvailability() async {
    // Wait a brief moment to ensure UI build
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final service = ref.read(digitalInkServiceProvider);
    
    // Always check existence of BOTH keys for full offline support
    final hasAm = await service.isModelDownloaded('am');
    final hasEn = await service.isModelDownloaded('en');
    
    // If either is missing, show the blocking "download all" dialog
    if (!hasAm || !hasEn) {
       if (mounted) {
         showDialog(
           context: context,
           // If they are in specific language mode, we could make it blocking ONLY if THAT language is missing.
           // But user requested "always download both". So we block if ANY is missing to ensure consistency.
           barrierDismissible: false, 
           builder: (context) => const DownloadModelDialog(isBlocking: true),
         ).then((_) {
            if (mounted) setState(() {}); 
         });
       }
    }
  }

  // _downloadModel removed as it's now handled by the dialog

  Future<void> _checkWork() async {
    final strokes = _drawingCanvasKey.currentState?.strokes ?? [];
    if (strokes.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(digitalInkServiceProvider);
      final langCode = widget.languageMode == 'AMHARIC' ? 'amharic' : 'english';
      
      final candidates = await service.recognize(strokes, langCode);
      
      bool isCorrect = false;
      if (candidates.contains(widget.targetChar)) {
        isCorrect = true;
      } else if (widget.languageMode != 'AMHARIC') {
         isCorrect = candidates.any((c) => c.toLowerCase() == widget.targetChar.toLowerCase());
      }
      
      if (mounted) {
        setState(() {
          _isCorrect = isCorrect;
          _showResult = true;
          _isLoading = false;
        });
        
        widget.onResult(isCorrect);
        
        if (isCorrect) {
          audioService.playSuccess();
        } else {
          audioService.playError();
        }
      }
      
    } catch (e) {
      debugPrint("Recognition error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFeedbackMessage() {
    final rand = DateTime.now().millisecondsSinceEpoch;
    if (_isCorrect) {
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
      return messages[rand % messages.length];
    } else {
      final messages = [
        "Almost there! Try again! 💪",
        "Good effort! Let's try once more! 🌈",
        "Nice try! One more time! 🎯",
        "You're learning! Try again! 📝",
      ];
      return messages[rand % messages.length];
    }
  }

  void _clearCanvas() {
    audioService.playClick();
    _drawingCanvasKey.currentState?.clear();
    // Also hide result when clearing, effectively "Trying Again"
    setState(() {
      _showResult = false;
    });
  }
  
  void _handleNext() {
    audioService.playClick();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(downloadProgressProvider);
    final isDownloading = downloadState.status == DownloadStatus.downloading;

    if (isDownloading) {
      return _buildDownloadingState(downloadState);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Canvas Container with Overlay
        // Increased height as requested "make the board a little bigger"
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  DrawingCanvas(
                    key: _drawingCanvasKey,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    strokeColor: isDark ? Colors.white : Colors.black,
                    strokeWidth: 8.0,
                  ),
                  
                  // Guidelines
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _GuidelinesPainter(
                          color: theme.colorScheme.onSurface.withValues(alpha:0.1),
                        ),
                      ),
                    ),
                  ),

                  // Removed corner clear button as requested
                    
                  // Result Overlay
                  if (_showResult)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: (_isCorrect ? Colors.green : Colors.orange).withValues(alpha:0.9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isCorrect ? LucideIcons.checkCircle2 : LucideIcons.refreshCw,
                                color: Colors.white,
                                size: 64,
                              ).animate().scale(curve: Curves.elasticOut),
                              const SizedBox(height: 16),
                              Text(
                                _getFeedbackMessage(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ).animate().fadeIn(),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    
                  // Loading Overlay
                  if (_isLoading)
                     Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha:0.3),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Buttons
        SizedBox(
          height: 64, // Slightly taller buttons
          child: _buildActionButtons(theme),
        ),
        const SizedBox(height: 48), // Space at bottom as requested
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildActionButtons(ThemeData theme) {
    if (_showResult) {
       // Result State Buttons
       return Row(
          children: [
            // Try Again
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                   audioService.playClick();
                   _drawingCanvasKey.currentState?.clear();
                   setState(() => _showResult = false); // Retry same letter
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
                icon: Icon(LucideIcons.refreshCw, color: theme.colorScheme.primary),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Next (If correct)
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isCorrect ? _handleNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCorrect ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                icon: const Icon(LucideIcons.arrowRight),
                label: Text(
                  'Next Question',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
       );
    } else {
       // Input State Buttons
       return Row(
         children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearCanvas,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: Colors.red.shade400),
                ),
                icon: Icon(LucideIcons.trash2, color: Colors.red.shade400),
                label: Text(
                  'Clear',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.red.shade400),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkWork,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADE80),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: const Color(0xFF4ADE80).withValues(alpha:0.4),
                ),
                icon: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(LucideIcons.check),
                label: Text(
                  _isLoading ? "Checking..." : "Check My Work",
                  style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),
         ],
       );
    }
  }

  Widget _buildDownloadingState(DownloadProgress progress) {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withValues(alpha:0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            "Downloading Resources...",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "${(progress.progress * 100).toInt()}%",
            style: GoogleFonts.poppins(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Copied helper from LetterTraceScreen
class _GuidelinesPainter extends CustomPainter {
  final Color color;
  _GuidelinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final y = size.height / 2;
    _drawDashedLine(canvas, Offset(20, y), Offset(size.width - 20, y), paint);
    _drawDashedLine(canvas, Offset(20, y - 60), Offset(size.width - 20, y - 60), paint..color = color.withValues(alpha:0.5));
    _drawDashedLine(canvas, Offset(20, y + 60), Offset(size.width - 20, y + 60), paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    final distance = (end - start).distance;
    final direction = (end - start) / distance;
    double drawn = 0;
    while (drawn < distance) {
      final drawStart = start + direction * drawn;
      final drawEnd = start + direction * (drawn + dashWidth).clamp(0, distance);
      canvas.drawLine(drawStart, drawEnd, paint);
      drawn += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
