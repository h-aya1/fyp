import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './persistence_service.dart';
import '../models/sync_queue_item.dart';

/// Background sync service for cloud backup.
/// 
/// Phase 1: Simple best-effort sync. No authentication, no RLS.
/// Syncs queued operations to Supabase when online.
/// 
/// Rules:
/// - Background only (never blocks UI)
/// - Last-write-wins (no conflict resolution)
/// - Failures remain queued for retry
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final PersistenceService _persistence = PersistenceService();
  bool _isSyncing = false;
  bool _isInitialized = false;

  /// Check if Supabase is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize Supabase (optional - app works without this)
  /// 
  /// Phase 1: No authentication required.
  /// Set SUPABASE_URL and SUPABASE_ANON_KEY in environment or hardcode for testing.
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('✅ Supabase initialized for sync');

      // Start listening for connectivity changes
      _startConnectivityListener();
    } catch (e) {
      debugPrint('⚠️ Supabase initialization failed: $e');
      debugPrint('📱 App will continue in offline-only mode');
      // App continues to work offline
    }
  }

  /// Listen for connectivity changes and trigger sync
  void _startConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((results) {
      // connectivity_plus returns List<ConnectivityResult> in newer versions
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        debugPrint('🌐 Network connected, triggering sync...');
        syncPendingOperations();
      }
    });
  }

  /// Sync all pending operations to Supabase
  /// 
  /// This is a background operation that never blocks the UI.
  Future<void> syncPendingOperations() async {
    if (!_isInitialized) {
      debugPrint('⚠️ Supabase not initialized, skipping sync');
      return;
    }

    if (_isSyncing) {
      debugPrint('⏳ Sync already in progress, skipping...');
      return;
    }

    _isSyncing = true;

    try {
      final pendingItems = await _persistence.getPendingSyncItems();

      if (pendingItems.isEmpty) {
        debugPrint('✅ No pending sync operations');
        _isSyncing = false;
        return;
      }

      debugPrint('📤 Syncing ${pendingItems.length} operations...');

      for (final item in pendingItems) {
        try {
          await _syncItem(item);
          await _persistence.removeSyncItem(item.id);
        } catch (e) {
          debugPrint('⚠️ Failed to sync item ${item.id}: $e');
          // Item remains in queue for retry
        }
      }

      debugPrint('✅ Sync completed');
    } catch (e) {
      debugPrint('❌ Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single queue item to Supabase
  Future<void> _syncItem(SyncQueueItem item) async {
    final supabase = Supabase.instance.client;
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    if (item.operation == 'insert') {
      // Upsert to handle duplicates (last-write-wins)
      await supabase.from(item.tableName).upsert(payload);
      debugPrint('✅ Synced ${item.tableName}/${item.recordId}');
    } else if (item.operation == 'update') {
      await supabase
          .from(item.tableName)
          .update(payload)
          .eq('id', item.recordId);
      debugPrint('✅ Updated ${item.tableName}/${item.recordId}');
    }
  }

  /// Manually trigger sync (for testing or user-initiated sync)
  Future<void> manualSync() async {
    debugPrint('🔄 Manual sync triggered');
    await syncPendingOperations();
  }

  /// Check if we're currently online
  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  /// Get sync queue status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final stats = await _persistence.getStats();
    final online = await isOnline();

    return {
      'is_online': online,
      'is_syncing': _isSyncing,
      'pending_operations': stats['pending_sync'] ?? 0,
      'supabase_initialized': _isInitialized,
    };
  }
}
