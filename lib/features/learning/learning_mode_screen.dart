import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:camera/camera.dart';
import '../../core/audio_service.dart';
import '../camera/camera_screen.dart';

class LearningModeScreen extends StatefulWidget {
  const LearningModeScreen({super.key});

  @override
  State<LearningModeScreen> createState() => _LearningModeScreenState();
}

class _LearningModeScreenState extends State<LearningModeScreen> {
  // Mock data for the prototype
  final String _targetChar = 'A';
  final String _hintText = 'Start from the top down!';
  final int _currentRepetition = 2;
  final int _totalRepetitions = 5;

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
                    // Target Character
                    Text(
                      _targetChar,
                      style: GoogleFonts.poppins(
                        fontSize: 120,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                        height: 1,
                      ),
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
                            child: Stack(
                              children: [
                                // Embedded Camera
                                CameraScreen(
                                  onCaptured: (XFile file) {
                                    // Handle capture for validation
                                    debugPrint("Captured: ${file.path}");
                                  },
                                ),
                                
                                // Placeholder text if camera fails or loads (CameraScreen handles loading, but this is fallback UI visually)
                                // In a real app we might overlay instructions
                                
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

                    // Check My Work Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          audioService.playClick();
                          // Logic to check work
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Verification logic placeholder')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ADE80),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        icon: const Icon(LucideIcons.check),
                        label: Text(
                          "Check My Work",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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
}
