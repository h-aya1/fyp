import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio_service.dart';
import '../camera/camera_screen.dart';
import 'controllers/handwriting_controller.dart';
import 'controllers/learning_session_controller.dart';
import '../../main.dart';
import '../dashboard/models/child_model.dart';

class LearningModeScreen extends ConsumerStatefulWidget {
  final String mode;
  final Child child;
  
  const LearningModeScreen({
    super.key,
    required this.mode,
    required this.child,
  });

  @override
  ConsumerState<LearningModeScreen> createState() => _LearningModeScreenState();
}

class _LearningModeScreenState extends ConsumerState<LearningModeScreen> {
  late LearningSessionController _sessionController;
  final String _hintText = 'Start from the top down!';
  int _currentRepetition = 1;
  final int _totalRepetitions = 5;
  
  // Captured image state
  XFile? _capturedImage;
  
  @override
  void initState() {
    super.initState();
    // Initialize session controller with callback to update mastery
    _sessionController = LearningSessionController(
      onUpdateMastery: (String char, bool success) {
        ref.read(appStateProvider.notifier).updateMastery(char, success);
      },
    );
    // Start the session with the selected mode
    _sessionController.startSession(widget.child, widget.mode);
  }
  
  @override
  void dispose() {
    _sessionController.endSession();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Keep light green in light mode, use theme background in dark mode
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF0FDF4),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.home, size: 28, color: theme.iconTheme.color),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(LucideIcons.pause, size: 28, color: theme.iconTheme.color),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(LucideIcons.rotateCcw, size: 28, color: theme.iconTheme.color),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Target Character - listen to session changes
                    ListenableBuilder(
                      listenable: _sessionController,
                      builder: (context, _) {
                        final currentChar = _sessionController.session?.targetCharacter ?? 'A';
                        return Text(
                          currentChar,
                          style: GoogleFonts.poppins(
                            fontSize: 120,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.onSurface,
                            height: 1,
                          ),
                        );
                      },
                    ),
                    
                    // Hint
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3), // Keep Yellow for visibility
                        borderRadius: BorderRadius.circular(30),
                        border: isDark ? Border.all(color: Colors.transparent) : null, // Optional border
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.lightbulb, size: 18, color: Color(0xFF854D0E)),
                          const SizedBox(width: 8),
                          Text(
                            _hintText,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF854D0E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),

                    // Handwriting / Camera Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Handwriting",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Camera View Container
                          Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _capturedImage == null
                                ? Stack(
                                    children: [
                                      // Embedded Camera
                                      CameraScreen(
                                        onCaptured: (XFile file) {
                                          // Handle capture for validation
                                          debugPrint("Captured: ${file.path}");
                                          setState(() {
                                            _capturedImage = file;
                                          });
                                          // Reset AI state when new image is captured
                                          ref.read(handwritingControllerProvider.notifier).reset();
                                        },
                                      ),
                                      
                                      // Live View Badge
                                      Positioned(
                                        bottom: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "Live View",
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      // Display captured image
                                      Image.file(
                                        File(_capturedImage!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                      
                                      // AI Result Overlay
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final aiState = ref.watch(handwritingControllerProvider);
                                          final isCorrect = aiState.isCorrect ?? false;
                                          
                                          if (aiState.loading || aiState.isCorrect == null) {
                                            return const SizedBox.shrink();
                                          }

                                          return Positioned.fill(
                                            child: Container(
                                              color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.2),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      isCorrect ? LucideIcons.checkCircle2 : LucideIcons.xCircle,
                                                      color: isCorrect ? Colors.green : Colors.red,
                                                      size: 80,
                                                    ),
                                                    if (isCorrect) ...[
                                                      const SizedBox(height: 16),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _capturedImage = null;
                                                            _currentRepetition++;
                                                          });
                                                          ref.read(handwritingControllerProvider.notifier).reset();
                                                          _sessionController.advanceQuestion();
                                                          if (_currentRepetition > _totalRepetitions) {
                                                            // Session complete
                                                            Navigator.pop(context);
                                                          }
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.green,
                                                          foregroundColor: Colors.white,
                                                        ),
                                                        child: const Text('Next Question'),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      // Retake button
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _capturedImage = null;
                                            });
                                            ref.read(handwritingControllerProvider.notifier).reset();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white.withOpacity(0.9),
                                            foregroundColor: theme.colorScheme.primary,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(LucideIcons.camera, size: 16),
                                          label: Text(
                                            "Retake",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Captured badge
                                      Positioned(
                                        bottom: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4ADE80).withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(LucideIcons.check, size: 12, color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Captured",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // Voice Assistant Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED), // Keep Beige for consistency
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.mic, color: Color(0xFF9A3412), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Voice assistant active",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9A3412),
                              ),
                            ),
                          ),
                          const Icon(LucideIcons.mic, color: Color(0xFF9A3412), size: 20),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Progress
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.repeat, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(width: 12),
                          Text(
                            "Repetitions: $_currentRepetition of $_totalRepetitions",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _currentRepetition / _totalRepetitions,
                                color: const Color(0xFF4ADE80),
                                backgroundColor: theme.dividerColor,
                                minHeight: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Feedback Message (AI Result)
                    _buildFeedbackBanner(ref),

                    // Check My Work Button
                    _buildActionButton(ref),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner(WidgetRef ref) {
    final aiState = ref.watch(handwritingControllerProvider);
    if (aiState.isCorrect != null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: aiState.isCorrect! ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: aiState.isCorrect! ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              aiState.isCorrect! ? LucideIcons.checkCircle2 : LucideIcons.alertCircle,
              color: aiState.isCorrect! ? Colors.green.shade700 : Colors.red.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                aiState.result?['description'] ?? '',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: aiState.isCorrect! ? Colors.green.shade900 : Colors.red.shade900,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (aiState.error != null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          aiState.error!,
          style: GoogleFonts.poppins(color: Colors.red.shade900),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButton(WidgetRef ref) {
    final aiState = ref.watch(handwritingControllerProvider);
    final isLoading = aiState.loading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
                onPressed: (_capturedImage == null || isLoading)
            ? null
            : () async {
                audioService.playClick();
                final bytes = await File(_capturedImage!.path).readAsBytes();
                final currentChar = _sessionController.session?.targetCharacter ?? 'A';
                await ref.read(handwritingControllerProvider.notifier).analyze(bytes, currentChar);

                final newState = ref.read(handwritingControllerProvider);
                if (newState.isCorrect != null) {
                  final isCorrect = newState.isCorrect!;
                  
                  // Update session metrics
                  if (_sessionController.session != null) {
                    _sessionController.session!.registerAttempt(correct: isCorrect);
                  }
                  
                  // Update mastery via AppState
                  final currentChar = _sessionController.session?.targetCharacter ?? 'A';
                  ref.read(appStateProvider.notifier).updateMastery(currentChar, isCorrect);
                  
                  if (isCorrect) {
                    audioService.playSuccess();
                    audioService.speak("Well done!");
                  } else {
                    audioService.playError();
                    audioService.speak("Let's try one more time!");
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ADE80),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(LucideIcons.check),
        label: Text(
          isLoading ? "Analyzing..." : "Check My Work",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
