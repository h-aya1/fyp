import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../main.dart';
import '../learning/learning_mode_screen.dart';
import '../../core/audio_service.dart';
import '../dashboard/models/child_model.dart';

class KidsModeSelectionScreen extends ConsumerStatefulWidget {
  const KidsModeSelectionScreen({super.key});

  @override
  ConsumerState<KidsModeSelectionScreen> createState() => _KidsModeSelectionScreenState();
}

class _KidsModeSelectionScreenState extends ConsumerState<KidsModeSelectionScreen> {
  int _selectedModeIndex = 0;
  bool _voiceAssistance = true;
  double _difficulty = 1.0;

  final List<Map<String, dynamic>> _modes = [
    {'icon': LucideIcons.bookOpen, 'label': 'Random', 'color': const Color(0xFFFEF3C7), 'iconColor': const Color(0xFFD97706)}, // Yellow
    {'icon': LucideIcons.home, 'label': 'English', 'color': const Color(0xFFDBEAFE), 'iconColor': const Color(0xFF2563EB)}, // Blue
    {'icon': LucideIcons.settings, 'label': 'Amharic', 'color': const Color(0xFFFCE7F3), 'iconColor': const Color(0xFFBE185D)}, // Pink 
    {'icon': LucideIcons.calculator, 'label': 'Numbers', 'color': const Color(0xFFFFEDD5), 'iconColor': const Color(0xFFC2410C)}, // Orange
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Auto-select child logic
    Child? selectedChild = state.selectedChild;
    if (selectedChild == null && state.children.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ref.read(appStateProvider).selectedChild == null) {
          ref.read(appStateProvider.notifier).selectChild(state.children.first);
        }
      });
      selectedChild = state.children.first;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: colorScheme.onSurface),
          onPressed: () {
             if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          'Start Learning',
          style: GoogleFonts.fredoka(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Who's Learning
            Text(
              "Who's playing?",
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: state.children.isEmpty
                  ? Center(child: Text("No children added", style: GoogleFonts.comicNeue(color: colorScheme.onSurface.withOpacity(0.5))))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.children.length,
                      clipBehavior: Clip.none,
                      itemBuilder: (context, index) {
                        final child = state.children[index];
                        final isSelected = selectedChild?.id == child.id;

                        return GestureDetector(
                          onTap: () {
                            ref.read(appStateProvider.notifier).selectChild(child);
                            audioService.playClick();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 20),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(color: const Color(0xFF4ADE80), width: 4)
                                            : Border.all(color: Colors.transparent, width: 4),
                                        boxShadow: isSelected ? [
                                          BoxShadow(
                                            color: const Color(0xFF4ADE80).withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          )
                                        ] : [],
                                      ),
                                      child: CircleAvatar(
                                        radius: 36,
                                        backgroundImage: NetworkImage(child.avatar),
                                        backgroundColor: isDark ? colorScheme.surface : Colors.grey.shade100,
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4ADE80),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: isDark ? theme.cardTheme.color! : Colors.white, width: 3),
                                          ),
                                          child: const Icon(LucideIcons.check, size: 14, color: Colors.white),
                                        ),
                                      ).animate().scale(curve: Curves.elasticOut),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  child.name,
                                  style: GoogleFonts.fredoka(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.5),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 32),

            // Choose Mode
            Text(
              "Choose a Subject",
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: _modes.length,
              itemBuilder: (context, index) {
                final mode = _modes[index];
                final isSelected = _selectedModeIndex == index;
                final modeBgColor = isDark ? (mode['color'] as Color).withOpacity(0.2) : mode['color'];

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedModeIndex = index);
                    audioService.playClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: modeBgColor, 
                      borderRadius: BorderRadius.circular(24),
                      border: isSelected 
                        ? Border.all(color: mode['iconColor'], width: 3) 
                        : Border.all(color: isDark ? theme.dividerColor : Colors.transparent, width: 2),
                      boxShadow: isSelected ? [
                         BoxShadow(color: (mode['color'] as Color).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
                      ] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                             color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.6),
                             shape: BoxShape.circle,
                          ),
                          child: Icon(mode['icon'], size: 32, color: mode['iconColor']),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mode['label'],
                          style: GoogleFonts.fredoka(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: colorScheme.onSurface, 
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: (300 + (index * 100)).ms).fadeIn().scale();
              },
            ),

            const SizedBox(height: 32),

            // Difficulty
            Text(
              "Difficulty Level",
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ).animate().fadeIn(delay: 600.ms).slideX(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(24),
                color: theme.cardTheme.color,
                 boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,4))
                ]
              ),
              child: Column(
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Row(
                         children: [
                           Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(LucideIcons.barChart2, color: Colors.orange, size: 20),
                           ),
                           const SizedBox(width: 12),
                           Text("Challenge Level", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                         ],
                       ),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: _difficulty == 0 ? Colors.green.withOpacity(0.2) : (_difficulty == 1 ? Colors.orange.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                           borderRadius: BorderRadius.circular(20),
                         ),
                         child: Text(
                           _difficulty == 0 ? "Easy" : (_difficulty == 1 ? "Medium" : "Hard"),
                           style: GoogleFonts.poppins(
                             fontWeight: FontWeight.bold,
                             fontSize: 12,
                             color: _difficulty == 0 ? Colors.green : (_difficulty == 1 ? Colors.orange : Colors.red),
                           ),
                         ),
                       ),
                     ],
                   ),
                   Slider(
                     value: _difficulty,
                     min: 0,
                     max: 2,
                     divisions: 2,
                     activeColor: const Color(0xFF4ADE80),
                     inactiveColor: isDark ? colorScheme.surface : Colors.grey.shade200,
                     onChanged: (val) => setState(() => _difficulty = val),
                   ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 48),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: (state.children.isEmpty) ? null : () {
                  audioService.playClick();
                  final childToUse = selectedChild ?? state.children.first;
                  String modeString;
                  switch (_modes[_selectedModeIndex]['label']) {
                    case 'English': modeString = 'ENGLISH'; break;
                    case 'Amharic': modeString = 'AMHARIC'; break;
                    case 'Numbers': modeString = 'NUMBERS'; break;
                    default: modeString = 'RANDOM'; break;
                  }
                  
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => LearningModeScreen(
                        mode: modeString,
                        child: childToUse,
                      )
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADE80),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 8,
                  shadowColor: const Color(0xFF4ADE80).withOpacity(0.4),
                ),
                child: Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                      const Icon(LucideIcons.play, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        "Start Adventure",
                        style: GoogleFonts.fredoka(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                   ],
                ),
              ),
            ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.elasticOut),
             const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
