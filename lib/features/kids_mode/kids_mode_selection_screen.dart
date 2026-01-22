import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
    {'icon': LucideIcons.settings, 'label': 'Amharic', 'color': const Color(0xFFFCE7F3), 'iconColor': const Color(0xFFBE185D)}, // Pink (Settings icon placeholder for Amharic specific symbol)
    {'icon': LucideIcons.calculator, 'label': 'Numbers', 'color': const Color(0xFFFFEDD5), 'iconColor': const Color(0xFFC2410C)}, // Orange
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Ensure we have a selected child, default to first if available
    Child? selectedChild = state.selectedChild;
    if (selectedChild == null && state.children.isNotEmpty) {
      // Auto-select the first child if none is selected
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
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.appBarTheme.foregroundColor),
          onPressed: () {
             if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          'Choose Child & Mode',
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
              "Who's Learning?",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: state.children.isEmpty
                  ? Center(child: Text("No children added", style: GoogleFonts.poppins(color: colorScheme.onSurface)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.children.length,
                      itemBuilder: (context, index) {
                        final child = state.children[index];
                        final isSelected = selectedChild?.id == child.id;

                        return GestureDetector(
                          onTap: () {
                            ref.read(appStateProvider.notifier).selectChild(child);
                            audioService.playClick();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(color: const Color(0xFF4ADE80), width: 3)
                                            : null,
                                      ),
                                      child: CircleAvatar(
                                        radius: 32,
                                        backgroundImage: NetworkImage(child.avatar),
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF4ADE80),
                                            shape: BoxShape.circle,
                                            // Make border color match background to "cut out"
                                            border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)), 
                                          ),
                                          child: const Icon(LucideIcons.check, size: 12, color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  child.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 24),

            // Choose Mode
            Text(
              "Choose Your Mode",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              itemCount: _modes.length,
              itemBuilder: (context, index) {
                final mode = _modes[index];
                final isSelected = _selectedModeIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedModeIndex = index);
                    audioService.playClick();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: mode['color'], // These are pastel colors, check visibility in dark mode? 
                      // Pastels might look harsh or bright in dark mode, but they are "buttons" so it's acceptable.
                      // Alternatively, use a darker variant if theme.brightness == Brightness.dark
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? Border.all(color: const Color(0xFF4ADE80), width: 3) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(mode['icon'], size: 32, color: mode['iconColor']),
                        const SizedBox(height: 8),
                        Text(
                          mode['label'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF1E293B), // Keep dark text on pastel backgrounds
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Learning Settings
            Text(
              "Learning Settings",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            // Voice Assist
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(16),
                color: theme.cardTheme.color,
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(LucideIcons.mic, color: Color(0xFF4ADE80)),
                title: Text(
                  "Voice Assistance",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                ),
                subtitle: Text(
                  "Enabled for pronunciation help",
                  style: GoogleFonts.poppins(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                ),
                value: _voiceAssistance,
                activeColor: const Color(0xFF4ADE80),
                onChanged: (val) => setState(() => _voiceAssistance = val),
              ),
            ),
            const SizedBox(height: 16),
            
            // Difficulty
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(16),
                color: theme.cardTheme.color,
              ),
              child: Column(
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Row(
                         children: [
                           const Icon(LucideIcons.slidersHorizontal, color: Colors.orange, size: 20),
                           const SizedBox(width: 12),
                           Text("Difficulty", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                         ],
                       ),
                       Text(
                         _difficulty == 0 ? "Easy" : (_difficulty == 1 ? "Medium" : "Hard"),
                         style: GoogleFonts.poppins(
                           fontWeight: FontWeight.bold,
                           color: Colors.orange,
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
                     onChanged: (val) => setState(() => _difficulty = val),
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (state.children.isEmpty) ? null : () {
                  audioService.playClick();
                  
                  // Use selected child or default to first child
                  final childToUse = selectedChild ?? state.children.first;
                  
                  // Map mode label to mode string
                  String modeString;
                  switch (_modes[_selectedModeIndex]['label']) {
                    case 'English':
                      modeString = 'ENGLISH';
                      break;
                    case 'Amharic':
                      modeString = 'AMHARIC';
                      break;
                    case 'Numbers':
                      modeString = 'NUMBERS';
                      break;
                    case 'Random':
                    default:
                      modeString = 'RANDOM';
                      break;
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(LucideIcons.play),
                label: Text(
                  "Start Learning",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
             const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
