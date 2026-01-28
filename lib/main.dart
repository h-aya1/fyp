import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/splash/splash_screen.dart';
import 'features/dashboard/models/child_model.dart';
import 'core/data_service.dart';
import 'core/audio_service.dart';
import 'core/app_theme.dart';
import 'core/services/persistence_service.dart';
import 'core/services/sync_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("⚠️ Failed to load .env file: $e");
  }

  // Initialize services
  await _initializeServices();

  runApp(const ProviderScope(child: FidelKidsApp()));
}

Future<void> _initializeServices() async {
  try {
    // 1. Initialize local SQLite database (required)
    await PersistenceService().initialize();
    debugPrint("✅ Local persistence initialized");

    // 2. Initialize audio service
    await audioService.init();
    debugPrint("✅ Audio service initialized");

    // 3. Initialize Supabase sync
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl != null &&
        supabaseAnonKey != null &&
        supabaseUrl.startsWith('http') && // Simple validation
        !supabaseUrl.contains('YOUR_SUPABASE_URL')) {
      await SyncService().initialize(
        supabaseUrl: supabaseUrl,
        supabaseAnonKey: supabaseAnonKey,
      );
      debugPrint("✅ Cloud sync initialized");
    } else {
      debugPrint("⚠️ Supabase credentials missing or invalid in .env - Offline mode only");
    }

    debugPrint("🔥 All services initialized");
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
  final int selectedTabIndex;
  final ThemeMode themeMode;

  AppState({ 
    this.children = const [],
    this.selectedChild,
    this.selectedTabIndex = 0,
    this.themeMode = ThemeMode.light,
  });

  AppState copyWith({
    List<Child>? children,
    Child? selectedChild,
    int? selectedTabIndex,
    ThemeMode? themeMode,
  }) {
    return AppState(
      children: children ?? this.children,
      selectedChild: selectedChild ?? this.selectedChild,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
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

  /// Add a new child (Phase 1: uses UUID instead of timestamp)
  void addChild(String name) async {
    // Create child using new PersistenceService (UUID-based)
    final newChild = await PersistenceService().createChild(nickname: name);
    
    // Convert to legacy model for UI compatibility
    final legacyChild = Child(
      id: newChild.id, // UUID instead of timestamp
      name: name,
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=$name',
      mastery: [],
    );

    final updatedChildren = [...state.children, legacyChild];
    state = state.copyWith(children: updatedChildren);
    
    debugPrint('✅ Child added with UUID: ${newChild.id}');
  }

  void selectChild(Child child) {
    state = state.copyWith(selectedChild: child);
  }

  void updateTabIndex(int index) {
    state = state.copyWith(selectedTabIndex: index);
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
