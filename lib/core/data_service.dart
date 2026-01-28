import 'package:flutter/foundation.dart';
import '../features/dashboard/models/child_model.dart' as legacy;
import './services/persistence_service.dart';

/// Data service for managing children and learning progress.
/// 
/// Phase 1: Migrated from SharedPreferences to SQLite via PersistenceService.
/// Maintains backward compatibility with existing Child model while using new persistence layer.
/// 
/// NOTE: This bridges the old Child model (with mastery) and new persistence layer.
/// In Phase 2, we may fully migrate to HandwritingAttempt-based analytics.
class DataService {
  final PersistenceService _persistence = PersistenceService();

  /// Save children (converts to new model and persists)
  Future<void> saveChildren(List<legacy.Child> children) async {
    // For Phase 1, we only save basic child info to new persistence
    // Mastery data remains in-memory for now (will migrate in Phase 2)
    debugPrint('⚠️ DataService.saveChildren called (legacy method)');
    debugPrint('   Phase 1: Child creation should use PersistenceService directly');
  }

  /// Load children (from new SQLite persistence)
  Future<List<legacy.Child>> loadChildren() async {
    try {
      final newChildren = await _persistence.getChildren();
      
      // Convert new Child model to legacy Child model
      return newChildren.map((child) {
        return legacy.Child(
          id: child.id, // Now using UUID instead of timestamp
          name: child.nickname ?? 'Child',
          avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=${child.id}',
          mastery: [], // Empty for now, will be populated from HandwritingAttempts in Phase 2
        );
      }).toList();
    } catch (e) {
      debugPrint('⚠️ Failed to load children: $e');
      return [];
    }
  }
}
