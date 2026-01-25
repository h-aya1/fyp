import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/audio_service.dart';
import 'sequence_matrix/sequence_game_screen.dart';
import 'phonics_bubble/phonics_bubble_screen.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
          'Learning Games',
          style: GoogleFonts.fredoka(
             color: colorScheme.onSurface,
             fontSize: 24,
             fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          double childAspectRatio = constraints.maxWidth > 600 ? 0.75 : 0.7; 
          
          return GridView.count(
            padding: const EdgeInsets.all(24),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: childAspectRatio, 
            children: [
              GameCard(
                title: 'Sequence Memory',
                description: 'Watch the pattern and repeat it!',
                ageRange: '3-7 Yrs',
                progress: 'New',
                color: const Color(0xFFA78BFA), // Purple
                imageIcon: LucideIcons.brainCircuit,
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SequenceGameScreen(),
                    ),
                  );
                },
                delay: 200.ms,
              ),
              GameCard(
                title: 'Phonics Bubble',
                description: 'Pop bubbles to match sounds!',
                ageRange: '4-7 Yrs',
                progress: 'New',
                color: const Color(0xFF60A5FA), // Blue
                imageIcon: LucideIcons.messageCircle,
                onPlay: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhonicsBubbleScreen(),
                    ),
                  );
                },
                delay: 400.ms,
              ),
               GameCard(
                title: 'Letter Trace',
                description: 'Coming Soon!',
                ageRange: '3-5 Yrs',
                progress: 'Locked',
                color: isDark ? colorScheme.onSurface.withOpacity(0.2) : Colors.grey.shade400,
                imageIcon: LucideIcons.penTool,
                isLocked: true,
                delay: 600.ms,
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
  final Color color;
  final IconData imageIcon;
  final VoidCallback? onPlay;
  final bool isLocked;
  final Duration delay;

  const GameCard({
    super.key,
    required this.title,
    required this.description,
    required this.ageRange,
    required this.progress,
    required this.color,
    required this.imageIcon,
    this.onPlay,
    this.isLocked = false,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: theme.dividerColor),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Area
              Expanded(
                flex: 4, 
                child: Container(
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.transparent : color.withOpacity(0.15),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  width: double.infinity,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.surface : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: isLocked ? [] : [
                           BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,4))
                        ]
                      ),
                      child: Icon(imageIcon, size: 32, color: isLocked ? colorScheme.onSurface.withOpacity(0.3) : color),
                    ),
                  ),
                ),
              ),
              
              // Content
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             title,
                             style: GoogleFonts.fredoka(
                               fontWeight: FontWeight.w600,
                               fontSize: 16,
                               color: colorScheme.onSurface,
                             ),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                           ),
                           const SizedBox(height: 4),
                           Text(
                             description,
                             style: GoogleFonts.comicNeue(
                               fontSize: 14,
                               color: colorScheme.onSurface.withOpacity(0.6),
                               height: 1.2,
                             ),
                             maxLines: 2,
                             overflow: TextOverflow.ellipsis,
                           ),
                         ],
                       ),
                       
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(
                               color: colorScheme.surface,
                               borderRadius: BorderRadius.circular(8),
                               border: Border.all(color: theme.dividerColor),
                             ),
                             child: Text(
                               ageRange,
                               style: GoogleFonts.poppins(
                                 color: colorScheme.onSurface.withOpacity(0.5),
                                 fontSize: 10,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                           ),
                           
                           if (!isLocked)
                             GestureDetector(
                                onTap: () {
                                  audioService.playClick();
                                  if (onPlay != null) onPlay!();
                                },
                               child: Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(
                                   color: color,
                                   shape: BoxShape.circle,
                                   boxShadow: [
                                     BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0,4))
                                   ]
                                 ),
                                 child: const Icon(LucideIcons.play, size: 16, color: Colors.white),
                               ),
                             )
                           else
                             Icon(LucideIcons.lock, size: 20, color: colorScheme.onSurface.withOpacity(0.3)),
                         ],
                       ),
                    ],
                  ),
                ),
              )
            ],
          ),
          // Status Badge
           Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                  border: isDark ? Border.all(color: theme.dividerColor) : null,
                ),
                child: Row(
                  children: [
                     Icon(LucideIcons.star, size: 10, color: isLocked ? Colors.grey : Colors.orange),
                     const SizedBox(width: 4),
                     Text(
                      progress,
                      style: GoogleFonts.poppins(
                        color: colorScheme.onSurface,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ).animate(delay: delay).scale(curve: Curves.easeOutBack);
  }
}
