import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/audio_service.dart';
import '../../core/constants.dart';
import '../camera/camera_screen.dart';
import 'controllers/handwriting_controller.dart';
import 'widgets/writing_input_area.dart';
import 'controllers/learning_session_controller.dart';
import '../../main.dart';
import '../dashboard/models/child_model.dart';

enum LearningInputMode { camera, writing }

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
  int _currentRepetition = 1;
  final int _totalRepetitions = 5;
  
  // State
  XFile? _capturedImage;
  LearningInputMode _inputMode = LearningInputMode.camera;
  
  @override
  void initState() {
    super.initState();
    _sessionController = LearningSessionController(
      onUpdateMastery: (String char, bool success) {
        ref.read(appStateProvider.notifier).updateMastery(char, success);
      },
    );
    _sessionController.startSession(widget.child, widget.mode);
  }
  
  @override
  void dispose() {
    _sessionController.endSession();
    super.dispose();
  }

  void _registerAttempt(bool isCorrect) {
    if (_sessionController.session != null) {
      _sessionController.session!.registerAttempt(correct: isCorrect);
    }
    final currentChar = _sessionController.session?.targetCharacter ?? 'A';
    ref.read(appStateProvider.notifier).updateMastery(currentChar, isCorrect);
  }

  void _advance() {
    setState(() {
      _capturedImage = null;
      _currentRepetition++;
    });
    
    // Reset Camera AI state
    ref.read(handwritingControllerProvider.notifier).reset();
    
    _sessionController.advanceQuestion();
    if (_currentRepetition > _totalRepetitions) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use Column directly with Expanded to prevent scrolling as requested
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // SafeArea top only to maximize vertical space
      body: SafeArea(
        bottom: false, 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Header Row (Home, Tools)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     IconButton(
                      icon: Icon(LucideIcons.home, size: 28, color: theme.iconTheme.color),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // Repetitions (Small & Compact at top right to save space)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.repeat, size: 14, color: theme.colorScheme.onSurface.withValues(alpha:0.5)),
                          const SizedBox(width: 8),
                          Text(
                            "$_currentRepetition/$_totalRepetitions",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Target Character (Grand & Colorful - Blue Hue)
              Expanded(
                 flex: 2,
                 child: Container(
                   padding: const EdgeInsets.only(top: 0),
                   alignment: Alignment.topCenter,
                   child: ListenableBuilder(
                    listenable: _sessionController,
                    builder: (context, _) {
                      final currentChar = _sessionController.session?.targetCharacter ?? 'A';
                      return ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF60A5FA)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          currentChar,
                          style: GoogleFonts.poppins(
                            fontSize: 160,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ).animate(key: ValueKey(currentChar))
                         .scale(curve: Curves.elasticOut, duration: 600.ms)
                         .shimmer(duration: 1200.ms, delay: 500.ms),
                      );
                    },
                  ),
                 ),
              ),
              
              const SizedBox(height: 12),

              // Mode Switcher (Smaller)
              Center(
                child: _ModeSwitcher(
                  currentMode: _inputMode,
                  onModeChanged: (mode) {
                    setState(() => _inputMode = mode);
                    audioService.playClick();
                    setState(() => _capturedImage = null);
                    ref.read(handwritingControllerProvider.notifier).reset();
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Main Interaction Area (Maximized)
              Expanded(
                flex: 4,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _inputMode == LearningInputMode.camera
                      ? _buildCameraCard(theme, isDark)
                      : _buildWritingCard(theme, isDark),
                ),
              ),

              const SizedBox(height: 80), // Increased space at bottom as requested
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWritingCard(ThemeData theme, bool isDark) {
    return Container(
      key: const ValueKey('writing'),
      width: double.infinity,
      // Use no padding or minimal to maximize canvas
      padding: const EdgeInsets.all(4), 
      child: ListenableBuilder(
            listenable: _sessionController,
            builder: (context, _) {
              final char = _sessionController.session?.targetCharacter ?? '';
              String lang = 'ENGLISH';
              if (AppConstants.amharicAlphabet.contains(char)) {
                lang = 'AMHARIC';
              }
              
              return WritingInputArea(
                targetChar: char,
                languageMode: lang,
                onResult: (isCorrect) => _registerAttempt(isCorrect),
                onNext: _advance,
              );
            },
          ),
    );
  }

  Widget _buildCameraCard(ThemeData theme, bool isDark) {
    return Container(
      key: const ValueKey('camera'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4), // Minimal padding
      child: Column(
        children: [
          // Camera View - maximize space
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: _capturedImage == null
                    ? Stack(
                        children: [
                          CameraScreen(
                            onCaptured: (XFile file) {
                              setState(() => _capturedImage = file);
                              ref.read(handwritingControllerProvider.notifier).reset();
                            },
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Live View",
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          Image.file(File(_capturedImage!.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                          
                          // Result Overlay (Matching Writing Mode)
                          Consumer(
                            builder: (context, ref, child) {
                              final aiState = ref.watch(handwritingControllerProvider);
                              final isCorrect = aiState.isCorrect;
                              
                              if (aiState.loading) {
                                 return Container(
                                    color: Colors.black.withValues(alpha:0.3),
                                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                                 );
                              }

                              if (isCorrect == null) return const SizedBox.shrink();

                              final color = isCorrect ? Colors.green : Colors.orange;

                              return Positioned.fill(
                                child: Container(
                                  color: color.withValues(alpha:0.9),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isCorrect ? LucideIcons.checkCircle2 : LucideIcons.refreshCw,
                                        color: Colors.white,
                                        size: 64,
                                      ).animate().scale(curve: Curves.elasticOut),
                                      const SizedBox(height: 16),
                                      Text(
                                        _getFeedbackMessage(isCorrect),
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
                              ).animate().fadeIn();
                            },
                          ),
                        ],
                      ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Fixed Height Buttons Area
          SizedBox(
            height: 60,
            child: _buildCameraActionButtons(ref),
          ),
        ],
      ),
    );
  }

  String _getFeedbackMessage(bool isCorrect) {
    final rand = DateTime.now().millisecondsSinceEpoch;
    if (isCorrect) {
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

  Widget _buildCameraActionButtons(WidgetRef ref) {
    final aiState = ref.watch(handwritingControllerProvider);
    final isLoading = aiState.loading;
    final isCorrect = aiState.isCorrect;

    // Result State
    if (isCorrect != null) {
       return Row(
          children: [
            // Try Again
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                   audioService.playClick();
                   setState(() => _capturedImage = null);
                   ref.read(handwritingControllerProvider.notifier).reset();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: Colors.blue),
                ),
                icon: const Icon(LucideIcons.refreshCw, color: Colors.blue),
                label: Text(
                  'Retake',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Next (If correct)
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isCorrect ? () {
                   audioService.playClick();
                   _advance();
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect ? Colors.green : Colors.grey,
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
    }
    
    // Initial State (No Capture)
    if (_capturedImage == null) {
       // Just a visual placeholder or message could go here if needed, 
       // but typically we want the camera to maximize space.
       // We can return a disabled 'Check' button or 'Capture' hint logic 
       // but CameraScreen handles capture on tap/shutter often. 
       // Let's keep it clean or add a "Ready" indicator.
       return Container(
          alignment: Alignment.center,
          child: Text("Tap button to capture", 
             style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
       );
    }

    // Captured but not checked
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () async {
          audioService.playClick();
          final bytes = await File(_capturedImage!.path).readAsBytes();
          final currentChar = _sessionController.session?.targetCharacter ?? 'A';
          
          await ref.read(handwritingControllerProvider.notifier).analyze(bytes, currentChar);
          
          final newState = ref.read(handwritingControllerProvider);
          if (newState.isCorrect != null) {
             _registerAttempt(newState.isCorrect!);
             if (newState.isCorrect!) {
               audioService.playSuccess();
             } else {
               audioService.playError();
             }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: const Color(0xFF2563EB).withValues(alpha:0.4),
        ),
        icon: isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(LucideIcons.scanLine),
        label: Text(
          isLoading ? "Scanning..." : "Check Photo",
          style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  final LearningInputMode currentMode;
  final Function(LearningInputMode) onModeChanged;

  const _ModeSwitcher({
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Smaller dimensions as requested
    const double height = 48; // Reduced from 64
    const double width = 240; // Reduced from 320
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha:0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            alignment: currentMode == LearningInputMode.camera
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: width / 2,
              height: height,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: currentMode == LearningInputMode.camera 
                      ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)] 
                      : [const Color(0xFFA855F7), const Color(0xFF9333EA)], 
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (currentMode == LearningInputMode.camera 
                        ? const Color(0xFF3B82F6) 
                        : const Color(0xFFA855F7)).withValues(alpha:0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          
          Row(
            children: [
              _buildOption(
                context,
                icon: LucideIcons.camera,
                label: "Camera",
                mode: LearningInputMode.camera,
                isSelected: currentMode == LearningInputMode.camera,
              ),
              _buildOption(
                context,
                icon: LucideIcons.penTool,
                label: "Writing",
                mode: LearningInputMode.writing,
                isSelected: currentMode == LearningInputMode.writing,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required LearningInputMode mode,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Row(
              key: ValueKey(isSelected),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16, // Smaller icon
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha:0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.w600,
                    fontSize: 14, // Smaller font
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha:0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
