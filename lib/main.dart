import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/splash/splash_screen.dart';
import 'features/dashboard/models/child_model.dart';
import 'core/data_service.dart';
import 'core/audio_service.dart';
import 'core/app_theme.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio service
  await _initializeServices();

  runApp(const ProviderScope(child: FidelKidsApp()));
}

Future<void> _initializeServices() async {
  try {
    await audioService.init();
    debugPrint("🔥 Services initialized");
  } catch (e) {
    debugPrint("⚠️ Initialization error: $e");
  }
}

/// ---------- RIVERPOD STATE ----------

final appStateProvider =
    StateNotifierProvider<AppStateController, AppState>((ref) {
  return AppStateController();
});

class AppState {
  final List<Child> children;
  final Child? selectedChild;
  final ThemeMode themeMode;

  AppState({
    required this.children,
    this.selectedChild,
    this.themeMode = ThemeMode.light,
  });

  AppState copyWith({
    List<Child>? children,
    Child? selectedChild,
    ThemeMode? themeMode,
  }) {
    return AppState(
      children: children ?? this.children,
      selectedChild: selectedChild ?? this.selectedChild,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class AppStateController extends StateNotifier<AppState> {
  final DataService _dataService = DataService();

  AppStateController() : super(AppState(children: [])) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final children = await _dataService.loadChildren();
    state = state.copyWith(children: children);
  }

  void toggleTheme(bool isDark) {
    state = state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void addChild(String name) {
    final newChild = Child(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=$name',
      mastery: [],
    );

    final updatedChildren = [...state.children, newChild];
    _dataService.saveChildren(updatedChildren);

    state = state.copyWith(children: updatedChildren);
  }

  void selectChild(Child child) {
    state = state.copyWith(selectedChild: child);
  }

  void updateMastery(String char, bool success) {
    if (state.selectedChild == null) return;

    final selected = state.selectedChild!;
    final index = selected.mastery.indexWhere((m) => m.character == char);

    if (index != -1) {
      selected.mastery[index].attempts++;
      if (success) selected.mastery[index].successes++;
      selected.mastery[index].lastAttempt = DateTime.now();
    } else {
      selected.mastery.add(MasteryRecord(
        character: char,
        attempts: 1,
        successes: success ? 1 : 0,
        lastAttempt: DateTime.now(),
      ));
    }

    _dataService.saveChildren(state.children);
    state = state.copyWith(selectedChild: selected);
  }
}

/// ---------- APP ----------

class FidelKidsApp extends ConsumerWidget {
  const FidelKidsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    return MaterialApp(
      title: 'Fidel Kids',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.themeMode,
      home: const SplashScreen(),
    );
  }
}
