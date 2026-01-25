
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../main.dart';
import '../kids_mode/kids_mode_selection_screen.dart';
import '../games/games_hub_screen.dart';
import 'parent_dashboard_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';

class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final theme = Theme.of(context);

    // List of screens corresponding to bottom nav tabs.
    // Each screen is assigned a unique ValueKey so that AnimatedSwitcher 
    // knows when a transition should occur.
    final List<Widget> _screens = const [
      ParentDashboardScreen(key: ValueKey('Dashboard')),
      KidsModeSelectionScreen(key: ValueKey('KidsMode')),
      GamesHubScreen(key: ValueKey('Games')),
      SettingsScreen(key: ValueKey('Settings')),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // body handles screen transitions using AnimatedSwitcher.
      // This provides a smooth slide + fade effect when switching between tabs.
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Slide animation from the right (simulating forward movement)
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.05, 0.0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        child: _screens[appState.selectedTabIndex],
      ),
      // Custom animated navigation bar built with pure Flutter widgets.
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
