import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/audio_service.dart';
import 'digital_ink_service.dart';
import 'drawing_canvas.dart';
import 'letter_trace_controller.dart';

class LetterTraceScreen extends ConsumerStatefulWidget {
  const LetterTraceScreen({super.key});

  @override
  ConsumerState<LetterTraceScreen> createState() => _LetterTraceScreenState();
}

class _LetterTraceScreenState extends ConsumerState<LetterTraceScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey<DrawingCanvasState> _drawingCanvasKey = GlobalKey<DrawingCanvasState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(letterTraceControllerProvider);
    final controller = ref.read(letterTraceControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Handle downloading state completely separate
    if (state.phase == LetterTracePhase.downloading) {
       return _buildDownloadingScreen(context, colorScheme, isDark);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: state.phase == LetterTracePhase.menu
          ? _buildMenuScreen(context, controller, colorScheme, isDark)
          : _buildGameScreen(context, state, controller, theme, colorScheme, isDark),
    );
  }

  Widget _buildDownloadingScreen(BuildContext context, ColorScheme colorScheme, bool isDark) {
    final controller = ref.read(letterTraceControllerProvider.notifier);
    
    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : const Color(0xFFF0F9FF),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF021835), const Color(0xFF033E8A)]
                : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Consumer(
              builder: (context, ref, _) {
                final progress = ref.watch(downloadProgressProvider);
                
                return Column(
                  children: [
                    // Header with back button
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
                          onPressed: () {
                            final service = ref.read(digitalInkServiceProvider);
                            service.cancelDownload();
                            controller.goToMenu();
                          },
                        ),
                        const Spacer(),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Main download card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.surface : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status icon
                          _buildStatusIcon(progress, colorScheme),
                          const SizedBox(height: 24),
                          
                          // Title
                          Text(
                            _getStatusTitle(progress.status),
                            style: GoogleFonts.fredoka(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          
                          // Message
                          Text(
                            progress.message.isEmpty 
                                ? 'Preparing resources...' 
                                : progress.message,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          
                          // Progress bar
                          _buildProgressBar(progress, colorScheme, isDark),
                          const SizedBox(height: 16),
                          
                          // Connectivity indicators
                          _buildConnectivityIndicators(progress, colorScheme),
                          
                          // Error details
                          if (progress.status == DownloadStatus.failed && 
                              progress.errorDetails != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.alertTriangle, 
                                          color: Colors.red, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Error Details',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    progress.errorDetails!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.red.shade700,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Action buttons
                    if (progress.status == DownloadStatus.failed)
                      _buildDownloadActionButtons(context, controller, ref, colorScheme)
                    else if (progress.status != DownloadStatus.completed)
                      OutlinedButton.icon(
                        onPressed: () {
                          final service = ref.read(digitalInkServiceProvider);
                          service.cancelDownload();
                          controller.goToMenu();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32, 
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(LucideIcons.x),
                        label: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(DownloadProgress progress, ColorScheme colorScheme) {
    IconData icon;
    Color color;
    bool animate = false;
    
    switch (progress.status) {
      case DownloadStatus.idle:
      case DownloadStatus.checkingConnectivity:
        icon = LucideIcons.wifi;
        color = Colors.blue;
        animate = true;
        break;
      case DownloadStatus.checkingModel:
        icon = LucideIcons.search;
        color = Colors.purple;
        animate = true;
        break;
      case DownloadStatus.downloading:
        icon = LucideIcons.download;
        color = Colors.green;
        animate = true;
        break;
      case DownloadStatus.completed:
        icon = LucideIcons.checkCircle2;
        color = Colors.green;
        break;
      case DownloadStatus.failed:
        icon = LucideIcons.alertCircle;
        color = Colors.red;
        break;
    }
    
    Widget iconWidget = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 3),
      ),
      child: Icon(icon, color: color, size: 48),
    );
    
    if (animate) {
      return iconWidget
          .animate(onPlay: (c) => c.repeat())
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.1, 1.1),
            duration: 800.ms,
          )
          .then()
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1.0, 1.0),
            duration: 800.ms,
          );
    }
    return iconWidget.animate().scale(curve: Curves.elasticOut);
  }

  String _getStatusTitle(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.idle:
        return 'Preparing...';
      case DownloadStatus.checkingConnectivity:
        return 'Checking Connection';
      case DownloadStatus.checkingModel:
        return 'Checking Resources';
      case DownloadStatus.downloading:
        return 'Downloading AI Model';
      case DownloadStatus.completed:
        return 'Ready to Play!';
      case DownloadStatus.failed:
        return 'Download Failed';
    }
  }

  Widget _buildProgressBar(DownloadProgress progress, ColorScheme colorScheme, bool isDark) {
    final progressValue = progress.progress.clamp(0.0, 1.0);
    final isError = progress.status == DownloadStatus.failed;
    final isComplete = progress.status == DownloadStatus.completed;
    final isIndeterminate = progress.status == DownloadStatus.downloading && progressValue == 0.0;
    
    Color progressColor;
    if (isError) {
      progressColor = Colors.red;
    } else if (isComplete) {
      progressColor = Colors.green;
    } else {
      progressColor = const Color(0xFF60A5FA);
    }
    
    return Column(
      children: [
        // Progress percentage or status text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              isIndeterminate ? 'Downloading...' : '${(progressValue * 100).toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: isDark 
                ? Colors.white.withOpacity(0.1) 
                : Colors.black.withOpacity(0.05),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Animated progress fill (Indeterminate or Determinate)
                if (isIndeterminate)
                  LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: progressColor,
                    minHeight: 12,
                  )
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressValue,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isError 
                                ? [Colors.red.shade400, Colors.red.shade600]
                                : isComplete
                                    ? [Colors.green.shade400, Colors.green.shade600]
                                    : [const Color(0xFF60A5FA), const Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  
                // Shimmer effect when downloading (only show if not indeterminate to avoid visual clash)
                if (progress.status == DownloadStatus.downloading && !isIndeterminate)
                  Positioned.fill(
                    child: Container()
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(
                          duration: 1500.ms,
                          color: Colors.white.withOpacity(0.3),
                        ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectivityIndicators(DownloadProgress progress, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIndicator(
          'Internet',
          progress.hasInternet,
          progress.status == DownloadStatus.checkingConnectivity,
          LucideIcons.wifi,
        ),
        const SizedBox(width: 24),
        _buildIndicator(
          'Google',
          progress.canReachGoogle,
          progress.status == DownloadStatus.checkingConnectivity && progress.hasInternet,
          LucideIcons.cloud,
        ),
      ],
    );
  }

  Widget _buildIndicator(String label, bool isOk, bool isChecking, IconData icon) {
    Color color;
    if (isChecking) {
      color = Colors.orange;
    } else if (isOk) {
      color = Colors.green;
    } else {
      color = Colors.grey;
    }
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: isChecking
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Icon(
                  isOk ? LucideIcons.check : icon,
                  color: color,
                  size: 20,
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadActionButtons(
    BuildContext context,
    LetterTraceController controller,
    WidgetRef ref,
    ColorScheme colorScheme,
  ) {
    final state = ref.read(letterTraceControllerProvider);
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.goToMenu(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(LucideIcons.home),
            label: Text(
              'Back',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => controller.startGame(state.language),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF60A5FA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            icon: const Icon(LucideIcons.refreshCw),
            label: Text(
              'Retry Download',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuScreen(
    BuildContext context,
    LetterTraceController controller,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF021835), const Color(0xFF033E8A)]
              : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Title
            Icon(
              LucideIcons.penTool,
              size: 80,
              color: colorScheme.primary,
            ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
            const SizedBox(height: 24),
            Text(
              'Letter Trace',
              style: GoogleFonts.fredoka(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ).animate().fadeIn().slideY(begin: 0.3),
            const SizedBox(height: 8),
            Text(
              'Practice writing letters',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 48),

            // Language selection buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _buildLanguageButton(
                    context,
                    'English Letters',
                    'A B C D E F ...',
                    const Color(0xFF4ADE80),
                    LucideIcons.bookOpen,
                    () {
                      audioService.playClick();
                      controller.startGame(LetterLanguage.english);
                    },
                  ).animate().slideX(begin: -0.3, delay: 300.ms),
                  const SizedBox(height: 20),
                  _buildLanguageButton(
                    context,
                    'Amharic Letters',
                    'ሀ ለ ሐ መ ሠ ...',
                    const Color(0xFF60A5FA),
                    LucideIcons.languages,
                    () {
                      audioService.playClick();
                      controller.startGame(LetterLanguage.amharic);
                    },
                  ).animate().slideX(begin: 0.3, delay: 400.ms),
                ],
              ),
            ),

            const Spacer(flex: 2),
            
            // Error banner if exists (e.g. download failed)
            Consumer(builder: (context, ref, _) {
              final error = ref.watch(letterTraceControllerProvider).error;
              if (error != null) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.alertCircle, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text(error, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: color, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen(
    BuildContext context,
    LetterTraceState state,
    LetterTraceController controller,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final gameColor = state.language == LetterLanguage.amharic
        ? const Color(0xFF60A5FA)
        : const Color(0xFF4ADE80);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [colorScheme.surface, theme.scaffoldBackgroundColor]
              : [gameColor.withOpacity(0.1), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, state, controller, colorScheme, gameColor, isDark),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Target Letter Display
                    _buildLetterDisplay(state, colorScheme, isDark),

                    const SizedBox(height: 24),

                    // Drawing Canvas
                    _buildDrawingArea(state, isDark, colorScheme),

                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(state, controller, gameColor),

                    const SizedBox(height: 16),

                    // Progress
                    _buildProgressIndicator(state, gameColor, colorScheme),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    LetterTraceState state,
    LetterTraceController controller,
    ColorScheme colorScheme,
    Color gameColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : gameColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.home, color: Colors.white, size: 28),
                onPressed: () {
                  audioService.playClick();
                  controller.goToMenu();
                },
              ),
              // Score display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${state.score}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Correct answers (green)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${state.correctAnswers}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Incorrect answers (orange/red)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.xCircle, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${state.incorrectAnswers}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Language toggle
              IconButton(
                icon: Icon(
                  state.language == LetterLanguage.english
                      ? LucideIcons.bookOpen
                      : LucideIcons.languages,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  audioService.playClick();
                  controller.changeLanguage(
                    state.language == LetterLanguage.english
                        ? LetterLanguage.amharic
                        : LetterLanguage.english,
                  );
                  _drawingCanvasKey.currentState?.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLetterDisplay(LetterTraceState state, ColorScheme colorScheme, bool isDark) {
    final letter = state.currentLetter?.letter ?? 'A';
    final isAmharic = state.language == LetterLanguage.amharic;

    return Column(
      children: [
        Text(
          'Write the letter',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            letter,
            style: GoogleFonts.poppins(
              fontSize: isAmharic ? 100 : 120,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              height: 1,
            ),
          ),
        ).animate(
          key: ValueKey(letter),
        ).scale(curve: Curves.elasticOut, duration: 600.ms),
        const SizedBox(height: 8),
        // Pronunciation hint
        if (state.currentLetter?.pronunciation != null)
          GestureDetector(
            onTap: () {
              audioService.speak(state.currentLetter!.pronunciation!);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.volume2, size: 18, color: Color(0xFF854D0E)),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to hear',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF854D0E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDrawingArea(LetterTraceState state, bool isDark, ColorScheme colorScheme) {
    final canvasBackground = isDark ? const Color(0xFF1E293B) : Colors.white;
    final strokeColor = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Drawing canvas
            SizedBox(
              height: 280,
              width: double.infinity,
              child: DrawingCanvas(
                key: _drawingCanvasKey,
                repaintKey: _canvasKey,
                backgroundColor: canvasBackground,
                strokeColor: strokeColor,
                strokeWidth: 8.0,
              ),
            ),

            // Guidelines (optional dotted lines)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GuidelinesPainter(
                    color: colorScheme.onSurface.withOpacity(0.1),
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (state.isLoading && state.phase != LetterTracePhase.downloading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),

            // Result overlay
            if (state.phase == LetterTracePhase.result)
              _buildResultOverlay(state, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildResultOverlay(LetterTraceState state, ColorScheme colorScheme) {
    final isCorrect = state.lastResult == EvaluationResult.correct;
    final color = isCorrect ? Colors.green : Colors.orange;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
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
                state.feedbackMessage ?? (isCorrect ? 'Great job!' : 'Try again!'),
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
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildActionButtons(
    LetterTraceState state,
    LetterTraceController controller,
    Color gameColor,
  ) {
    final isResult = state.phase == LetterTracePhase.result;
    final isCorrect = state.lastResult == EvaluationResult.correct;

    return Row(
      children: [
        // Clear button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: state.isLoading
                ? null
                : () {
                    audioService.playClick();
                    _drawingCanvasKey.currentState?.clear();
                    if (isResult) {
                      controller.retryLetter();
                    }
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: gameColor),
            ),
            icon: Icon(LucideIcons.trash2, color: gameColor),
            label: Text(
              isResult ? 'Try Again' : 'Clear',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: gameColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Check / Next button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: state.isLoading
                ? null
                : () async {
                    audioService.playClick();
                    if (isResult) {
                      controller.nextLetter();
                      _drawingCanvasKey.currentState?.clear();
                    } else {
                      // Get strokes data directly
                      final strokes = _drawingCanvasKey.currentState?.strokes ?? [];
                      if (strokes.isNotEmpty) {
                        await controller.evaluateStrokes(strokes);
                        final newState = ref.read(letterTraceControllerProvider);
                        if (newState.lastResult == EvaluationResult.correct) {
                          audioService.playSuccess();
                        } else if (newState.lastResult == EvaluationResult.incorrect) {
                          audioService.playError();
                        }
                      } else {
                         // Empty canvas feedback?
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isResult && isCorrect ? Colors.green : gameColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            icon: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(isResult ? LucideIcons.arrowRight : LucideIcons.check),
            label: Text(
              state.isLoading
                  ? 'Checking...'
                  : isResult
                      ? 'Next Letter'
                      : 'Check My Work',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(
    LetterTraceState state,
    Color gameColor,
    ColorScheme colorScheme,
  ) {
    final totalQuestions = state.totalAttempts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.helpCircle, size: 20, color: gameColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Questions Answered: $totalQuestions',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (totalQuestions > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Accuracy: ${((state.correctAnswers / totalQuestions) * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing guidelines on the canvas
class _GuidelinesPainter extends CustomPainter {
  final Color color;

  _GuidelinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw horizontal center line
    final y = size.height / 2;
    _drawDashedLine(
      canvas,
      Offset(20, y),
      Offset(size.width - 20, y),
      paint,
    );
    
    // Draw top and bottom guidelines
    _drawDashedLine(
      canvas,
      Offset(20, y - 60),
      Offset(size.width - 20, y - 60),
      paint..color = color.withOpacity(0.5),
    );
    
     _drawDashedLine(
      canvas,
      Offset(20, y + 60),
      Offset(size.width - 20, y + 60),
      paint,
    );
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
