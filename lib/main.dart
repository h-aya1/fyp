import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/splash/splash_screen.dart';
import 'features/dashboard/models/child_model.dart';
import 'core/data_service.dart';
import 'core/audio_service.dart';
import 'core/app_theme.dart'; // Import AppTheme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await audioService.init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const BrightKidsApp(),
    ),
  );
}

class AppState extends ChangeNotifier {
  List<Child> _children = [];
  Child? _selectedChild;
  ThemeMode _themeMode = ThemeMode.light; // Default to light
  final DataService _dataService = DataService();

  List<Child> get children => _children;
  Child? get selectedChild => _selectedChild;
  ThemeMode get themeMode => _themeMode; // Getter

  AppState() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _children = await _dataService.loadChildren();
    notifyListeners();
  }
  
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void addChild(String name) {
    final newChild = Child(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=$name',
      mastery: [],
    );
    _children.add(newChild);
    _dataService.saveChildren(_children);
    notifyListeners();
  }

  void selectChild(Child child) {
    _selectedChild = child;
    notifyListeners();
  }

  void updateMastery(String char, bool success) {
    if (_selectedChild == null) return;
    
    final index = _selectedChild!.mastery.indexWhere((m) => m.character == char);
    if (index != -1) {
      _selectedChild!.mastery[index].attempts++;
      if (success) _selectedChild!.mastery[index].successes++;
      _selectedChild!.mastery[index].lastAttempt = DateTime.now();
    } else {
      _selectedChild!.mastery.add(MasteryRecord(
        character: char,
        attempts: 1,
        successes: success ? 1 : 0,
        lastAttempt: DateTime.now(),
      ));
    }
    _dataService.saveChildren(_children);
    notifyListeners();
  }
}

class BrightKidsApp extends StatelessWidget {
  const BrightKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>(); // Listen to state changes

    return MaterialApp(
      title: 'BrightKids',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.themeMode,
      home: const SplashScreen(),
    );
  }
}
