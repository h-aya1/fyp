
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../main.dart';

/// A custom bottom navigation bar that follows the visual energy and polish
/// of motion_tab_bar using only native Flutter widgets.
/// 
/// Key features:
/// - Floating pill-style active background.
/// - Icon scaling and color interpolation.
/// - Responsive height and sizing for phones and tablets.
class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Define navigation items
    final List<Map<String, dynamic>> navItems = [
      {'icon': LucideIcons.layoutDashboard, 'label': 'Home'},
      {'icon': LucideIcons.baby, 'label': 'Kids'},
      {'icon': LucideIcons.gamepad2, 'label': 'Play'},
      {'icon': LucideIcons.settings, 'label': 'Settings'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust sizing for tablets vs phones
        final double barHeight = constraints.maxWidth > 600 ? 80 : 70;
        final double iconSize = constraints.maxWidth > 600 ? 32 : 26;
        final double pillPadding = constraints.maxWidth > 600 ? 12 : 8;

        return Container(
          height: barHeight,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. The Floating Pill Background
              // AnimatedAlign handles the smooth movement across tabs.
              AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  -1.0 + (appState.selectedTabIndex * (2 / (navItems.length - 1))),
                  0.0,
                ),
                child: FractionallySizedBox(
                  widthFactor: 1 / navItems.length,
                  child: Container(
                    margin: EdgeInsets.all(pillPadding),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              // 2. The Interactive Icons layer
              Row(
                children: List.generate(navItems.length, (index) {
                  final isSelected = appState.selectedTabIndex == index;
                  
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => ref.read(appStateProvider.notifier).updateTabIndex(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // AnimatedScale provides the "pop" effect on selection
                          AnimatedScale(
                            scale: isSelected ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            child: Icon(
                              navItems[index]['icon'],
                              size: iconSize,
                              // Color interpolation logic
                              color: isSelected 
                                ? colorScheme.primary 
                                : (isDark ? Colors.white70 : Colors.grey[400]),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Subtle label appearance
                          if (isSelected)
                            AnimatedOpacity(
                              opacity: isSelected ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                navItems[index]['label'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
