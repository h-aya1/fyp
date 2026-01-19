import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../kids_mode/kids_mode_selection_screen.dart';
import '../games/games_hub_screen.dart';
import 'parent_dashboard_screen.dart';
import '../settings/settings_screen.dart';

// Placeholders for other screens
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Center(child: Text(title));
}

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
  
  // Allow access to state for switching tabs
  static _ParentHomeScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ParentHomeScreenState>();
  }
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    ParentDashboardScreen(),
    KidsModeSelectionScreen(), // Replaced placeholder
    const GamesHubScreen(),    // Replaced placeholder
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4ADE80),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.baby),
            label: 'Kids Mode',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.gamepad2),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
