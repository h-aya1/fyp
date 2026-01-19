import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/audio_service.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
           icon: Icon(LucideIcons.chevronLeft, color: theme.appBarTheme.foregroundColor),
           onPressed: () {
             // For tab navigation context, this might not be needed or could just go back if pushed
              if (Navigator.canPop(context)) Navigator.pop(context);
           },
        ),
        title: Text(
          'Games Hub',
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          // Dynamically adjust aspect ratio based on width to ensure content fits
          // Smaller ratio = Taller card.
          double childAspectRatio = constraints.maxWidth > 600 ? 0.75 : 0.55; 
          
          return GridView.count(
            padding: const EdgeInsets.all(24),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: childAspectRatio, 
            children: const [
              GameCard(
                title: 'Alphabet Match-Up',
                description: 'Match Amharic and English letters',
                ageRange: '3-6 Yrs',
                progress: '75%',
                imageColor: Color(0xFF93C5FD), // Light Blue
                badgeColor: Color(0xFF4ADE80), // Green for Badge
              ),
              GameCard(
                title: 'Tracing Adventure',
                description: 'Practice tracing letters and numbers',
                ageRange: '4-7 Yrs',
                progress: '90%',
                imageColor: Color(0xFFFDE047), // Yellow
                badgeColor: Color(0xFF4ADE80),
              ),
              GameCard(
                title: 'Sound Explorer',
                description: 'Listen and identify the sounds',
                ageRange: '3-5 Yrs',
                progress: '60%',
                imageColor: Color(0xFF86EFAC), // Green
                badgeColor: Color(0xFF4ADE80),
              ),
              GameCard(
                title: 'Word Builder',
                description: 'Drag and drop letters to form words',
                ageRange: '5-8 Yrs',
                progress: '45%',
                imageColor: Color(0xFFFDBA74), // Orange
                badgeColor: Color(0xFF4ADE80),
              ),
            ],
          );
        },
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String description;
  final String ageRange;
  final String progress;
  final Color imageColor;
  final Color badgeColor;

  const GameCard({
    super.key,
    required this.title,
    required this.description,
    required this.ageRange,
    required this.progress,
    required this.imageColor,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Illustration Area
          Expanded(
            flex: 3, // Reduced flex to give text more space if needed, or keep 4/5 split but strictly enforce constraints
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: imageColor.withOpacity(0.3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  width: double.infinity,
                  // Placeholder for actual game image
                  child: Icon(LucideIcons.gamepad2, size: 48, color: imageColor),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ageRange,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Try to be minimal
                children: [
                   Text(
                     title,
                     style: GoogleFonts.poppins(
                       fontWeight: FontWeight.bold,
                       fontSize: 14,
                       color: colorScheme.onSurface,
                     ),
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),
                   const SizedBox(height: 4),
                   Expanded( // Allow description to take available space
                     child: Text(
                       description,
                       style: GoogleFonts.poppins(
                         fontSize: 11,
                         color: colorScheme.onSurface.withOpacity(0.6),
                       ),
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                   const SizedBox(height: 8),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       // Progress Badge
                       Flexible( // Prevent right overflow
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                           decoration: BoxDecoration(
                             color: const Color(0xFFFFF7ED), // Keep beige for contrast with orange star? Or adapt.
                             // Let's keep it fixed for now as it's a specific "gold/star" aesthetic
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min, // Shrink wrap
                             children: [
                               const Icon(LucideIcons.star, size: 10, color: Colors.orange),
                               const SizedBox(width: 4),
                               Flexible( // Ensure text truncates if super small
                                 child: Text(
                                   "$progress Complete",
                                   style: GoogleFonts.poppins(
                                     fontSize: 9, 
                                     fontWeight: FontWeight.w600,
                                     color: const Color(0xFF9A3412),
                                   ),
                                   maxLines: 1,
                                   overflow: TextOverflow.ellipsis,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                       const SizedBox(width: 8), 
                       GestureDetector(
                         onTap: () {
                           audioService.playClick();
                           // Play game logic
                         },
                         child: Container(
                           padding: const EdgeInsets.all(8),
                           decoration: const BoxDecoration(
                             color: Color(0xFF4ADE80),
                             shape: BoxShape.circle,
                           ),
                           child: const Icon(LucideIcons.play, size: 16, color: Colors.white),
                         ),
                       ),
                     ],
                   ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
