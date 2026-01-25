import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'phonics_bubble_controller.dart';
import 'bubble_widget.dart';

class PhonicsBubbleScreen extends StatefulWidget {
  const PhonicsBubbleScreen({super.key});

  @override
  State<PhonicsBubbleScreen> createState() => _PhonicsBubbleScreenState();
}

class _PhonicsBubbleScreenState extends State<PhonicsBubbleScreen> {
  late PhonicsBubbleController _controller;
  final Map<String, Offset> _bubblePositions = {};
  final Random _random = Random();
  
  final List<Color> _bubbleColors = [
    const Color(0xFFFF6B6B), // Red
    const Color(0xFF4ECDC4), // Cyan
    const Color(0xFFFFBE0B), // Yellow
    const Color(0xFF8338EC), // Purple
    const Color(0xFFFB5607), // Orange
    const Color(0xFFFF006E), // Pink
  ];

  @override
  void initState() {
    super.initState();
    _controller = PhonicsBubbleController(onStateChanged: () {
      if (mounted) setState(() {});
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initGame();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updatePositions(BoxConstraints constraints) {
    _bubblePositions.removeWhere((key, value) => !_controller.activeBubbles.contains(key));
    
    double padding = 30;
    double bubbleSize = 120;
    double minX = padding;
    double maxX = constraints.maxWidth - bubbleSize - padding;
    double minY = padding + 160; 
    double maxY = constraints.maxHeight - bubbleSize - padding;
    
    if (maxX < minX) maxX = minX;
    if (maxY < minY) maxY = minY;

    for (String letter in _controller.activeBubbles) {
      if (!_bubblePositions.containsKey(letter)) {
         Offset newPos = Offset.zero;
         bool valid = false;
         int attempts = 0;
         
         while (!valid && attempts < 30) {
            double x = minX + _random.nextDouble() * (maxX - minX);
            double y = minY + _random.nextDouble() * (maxY - minY);
            newPos = Offset(x, y);
            
            valid = true;
            for (var other in _bubblePositions.values) {
               if ((other - newPos).distance < bubbleSize + 20) {
                 valid = false; 
                 break;
               }
            }
            attempts++;
         }
         _bubblePositions[letter] = newPos;
      }
    }
  }
  
  Color _getBubbleColor(String letter) {
    int index = letter.hashCode % _bubbleColors.length;
    return _bubbleColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isPlaying = _controller.currentPhase == GamePhase.playing;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor.withBlue(60)]
              : [const Color(0xFFF0F9FF), Colors.white],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isPlaying) {
               _updatePositions(constraints);
            }
            
            return Stack(
              children: [
                // --- Animated Background Elements ---
                ...List.generate(5, (index) => Positioned(
                  left: _random.nextDouble() * constraints.maxWidth,
                  top: _random.nextDouble() * constraints.maxHeight,
                  child: Icon(
                    LucideIcons.music, 
                    color: colorScheme.primary.withOpacity(0.05), 
                    size: 40 + _random.nextDouble() * 40
                  ).animate(onPlay: (c) => c.repeat()).moveY(begin: 0, end: -100, duration: (5 + index * 2).seconds).fadeOut(),
                )),

                // --- Header ---
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surface : colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 28),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.award, color: Colors.amber, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${_controller.correctPopsDisplay}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 24, 
                                      fontWeight: FontWeight.w900, 
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        if (isPlaying || _controller.currentPhase == GamePhase.prompt) ...[
                           const SizedBox(height: 16),
                           Text(
                             "Find and Pop", 
                             style: GoogleFonts.poppins(
                               color: Colors.white.withOpacity(0.9),
                               fontSize: 16,
                               fontWeight: FontWeight.w500,
                             )
                           ),
                           Text(
                             _controller.targetLetter, 
                             style: GoogleFonts.poppins(
                               fontSize: 48, 
                               fontWeight: FontWeight.w900, 
                               color: Colors.white,
                               letterSpacing: 2,
                             )
                           ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut),
                        ]
                      ],
                    ),
                  ),
                ),
                
                // --- Bubbles ---
                if (isPlaying)
                  ..._controller.activeBubbles.map((letter) {
                     Offset? pos = _bubblePositions[letter];
                     pos ??= const Offset(100, 300);
                     return Positioned(
                       left: pos.dx,
                       top: pos.dy,
                       child: BubbleWidget(
                         key: ValueKey(letter),
                         letter: letter,
                         color: _getBubbleColor(letter),
                         onCheck: _controller.handleTap,
                         onAnimationComplete: () => _controller.removeBubble(letter),
                       ),
                     );
                  }),
                  
                // --- Overlays ---
                if (_controller.currentPhase == GamePhase.prompt)
                   _buildCenterOverlay(
                      context,
                      title: "Get Ready!", 
                      subtitle: "Pop the letter ${_controller.targetLetter}",
                      icon: LucideIcons.playCircle,
                      color: colorScheme.secondary,
                   ),
                   
                if (_controller.currentPhase == GamePhase.result)
                   _buildCenterOverlay(
                      context,
                      title: "Super Star! 🌟",
                      subtitle: "Level Complete!",
                      icon: LucideIcons.thumbsUp,
                      color: Colors.orangeAccent,
                   ),

                // --- Menu Overlay ---
                if (_controller.currentPhase == GamePhase.menu)
                  Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Container(
                        width: 340,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark ? colorScheme.surface : Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 40)
                          ]
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Bubble Fun!", 
                              style: GoogleFonts.poppins(
                                fontSize: 32, 
                                fontWeight: FontWeight.w900,
                                color: colorScheme.primary,
                              )
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Choose a game mode", 
                              style: GoogleFonts.poppins(
                                fontSize: 16, 
                                color: isDark ? Colors.white70 : Colors.grey[600],
                              )
                            ),
                            const SizedBox(height: 32),
                            
                            _buildMenuButton(
                              context,
                              "Search Mode", 
                              "Find the hidden letters!", 
                              const Color(0xFF8338EC),
                              LucideIcons.search,
                              () => _controller.startGame(GameMode.search)
                            ),
                            const SizedBox(height: 20),
                            _buildMenuButton(
                              context,
                              "Fast Pop", 
                              "Quick! Pop them all!", 
                              const Color(0xFF3A86FF),
                              LucideIcons.zap,
                              () => _controller.startGame(GameMode.stream)
                            ),
                          ],
                        ),
                      ).animate().scale(curve: Curves.easeOutBack, duration: 500.ms),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, String subtitle, Color color, IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w900, 
                      fontSize: 18, 
                      color: color,
                    )
                  ),
                  Text(
                    subtitle, 
                    style: GoogleFonts.poppins(
                      fontSize: 13, 
                      color: isDark ? Colors.white60 : Colors.grey[700],
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.2, duration: 400.ms, curve: Curves.easeOutCubic);
  }
  
  Widget _buildCenterOverlay(BuildContext context, {
    required String title, 
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     return Center(
       child: Container(
         margin: const EdgeInsets.symmetric(horizontal: 40),
         padding: const EdgeInsets.all(32),
         decoration: BoxDecoration(
           color: isDark ? const Color(0xFF1E293B) : Colors.white,
           borderRadius: BorderRadius.circular(40),
           boxShadow: [
             BoxShadow(
               blurRadius: 30, 
               color: Colors.black.withOpacity(0.2),
               offset: const Offset(0, 10),
             )
           ]
         ),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: color.withOpacity(0.1),
                 shape: BoxShape.circle,
               ),
               child: Icon(icon, color: color, size: 60),
             ),
             const SizedBox(height: 24),
             Text(
               title, 
               style: GoogleFonts.poppins(
                 fontSize: 28, 
                 fontWeight: FontWeight.w900, 
                 color: color,
               )
             ),
             const SizedBox(height: 8),
             Text(
               subtitle, 
               textAlign: TextAlign.center,
               style: GoogleFonts.poppins(
                 fontSize: 18, 
                 fontWeight: FontWeight.w500,
                 color: isDark ? Colors.white70 : Colors.grey[600],
               )
             ),
           ],
         ),
       ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
     );
  }
}
