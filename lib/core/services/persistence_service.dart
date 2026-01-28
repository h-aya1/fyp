import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/child.dart';
import '../models/handwriting_attempt.dart';
import '../models/sync_queue_item.dart';

/// Local-first persistence service using SQLite.
/// 
/// Phase 1: All data is written to local SQLite first, then queued for sync.
/// The app works 100% offline. Cloud sync is a best-effort background operation.
/// 
/// NO AUTHENTICATION: Children are identified locally only via UUIDs.
class PersistenceService {
  static final PersistenceService _instance = PersistenceService._internal();
  factory PersistenceService() => _instance;
  PersistenceService._internal();

  Database? _database;

  /// Initialize the database (call before runApp)
  Future<void> initialize() async {
    if (_database != null) return;

    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'fidelkids.db');

      _database = await openDatabase(
        path,
        version: 2,
        onCreate: _createTables,
        onUpgrade: _onUpgrade,
      );

      debugPrint('✅ SQLite database initialized at $path');
    } catch (e) {
      debugPrint('❌ Database initialization failed: $e');
      rethrow;
    }
  }

  /// Create database tables
  Future<void> _createTables(Database db, int version) async {
    // Children table
    await db.execute('''
      CREATE TABLE children (
        id TEXT PRIMARY KEY,
        nickname TEXT,
        created_at TEXT,
        owner_id TEXT,
        claimed_at TEXT
      )
    ''');

    // Handwriting attempts table
    await db.execute('''
      CREATE TABLE handwriting_attempts (
        id TEXT PRIMARY KEY,
        child_id TEXT NOT NULL,
        target_character TEXT NOT NULL,
        shape_similarity TEXT NOT NULL,
        confidence_score REAL NOT NULL,
        feedback_text TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY (child_id) REFERENCES children(id)
      )
    ''');

    // Sync queue table (critical for offline-first)
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT
      )
    ''');

    // Indexes for performance
    await db.execute(
      'CREATE INDEX idx_attempts_child ON handwriting_attempts(child_id)',
    );
    await db.execute(
      'CREATE INDEX idx_attempts_created ON handwriting_attempts(created_at)',
    );

    debugPrint('✅ Database tables created');
  }

  /// Handle database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      debugPrint('🔄 Migrating to version 2: Adding ownership columns...');
      await db.execute('ALTER TABLE children ADD COLUMN owner_id TEXT');
      await db.execute('ALTER TABLE children ADD COLUMN claimed_at TEXT');
      debugPrint('✅ Migration to version 2 complete');
    }
  }

  Database get _db {
    if (_database == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  // ==================== CHILDREN ====================

  /// Create a new child (local-first)
  Future<Child> createChild({String? nickname}) async {
    final child = Child(nickname: nickname);

    // 1. Save locally
    await _db.insert('children', child.toJson());

    // 2. Queue for sync
    await _enqueueSyncOperation(
      tableName: 'children',
      recordId: child.id,
      operation: 'insert',
      payload: child.toJson(),
    );

    debugPrint('✅ Child created locally: ${child.id}');
    return child;
  }

  /// Get all children (from local SQLite)
  Future<List<Child>> getChildren() async {
    final results = await _db.query(
      'children',
      orderBy: 'created_at DESC',
    );

    return results.map((json) => Child.fromJson(json)).toList();
  }

  /// Get a single child by ID
  Future<Child?> getChildById(String id) async {
    final results = await _db.query(
      'children',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return Child.fromJson(results.first);
  }

  /// Get count of children that haven't been claimed yet
  Future<int> getUnclaimedChildrenCount() async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) FROM children WHERE owner_id IS NULL',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Claim all local children for a specific parent (Supabase User)
  Future<int> claimChildrenForParent(String ownerId) async {
    final now = DateTime.now();
    final claimedAtIso = now.toIso8601String();

    // 1. Find unclaimed children
    final unclaimed = await _db.query(
      'children',
      where: 'owner_id IS NULL',
    );

    if (unclaimed.isEmpty) return 0;

    debugPrint('🔐 Claiming ${unclaimed.length} children for parent $ownerId...');

    // 2. Update them locally
    final batch = _db.batch();
    for (final childJson in unclaimed) {
      batch.update(
        'children',
        {'owner_id': ownerId, 'claimed_at': claimedAtIso},
        where: 'id = ?',
        whereArgs: [childJson['id']],
      );
    }
    await batch.commit(noResult: true);

    // 3. Queue update operations for sync
    for (final childJson in unclaimed) {
      // Create updated child object to serialize
      final childId = childJson['id'] as String;
      final updatedChild = Child.fromJson(childJson).copyWith(
        ownerId: ownerId,
        claimedAt: now,
      );

      await _enqueueSyncOperation(
        tableName: 'children',
        recordId: childId,
        operation: 'update',
        payload: updatedChild.toJson(),
      );
    }

    debugPrint('✅ Successfully claimed ${unclaimed.length} children');
    return unclaimed.length;
  }

  // ==================== HANDWRITING ATTEMPTS ====================

  /// Save a handwriting attempt (local-first)
  /// 
  /// This is called immediately after AI evaluation.
  /// The learning flow never blocks on network.
  Future<HandwritingAttempt> saveHandwritingAttempt(
    HandwritingAttempt attempt,
  ) async {
    // 1. Save locally
    await _db.insert('handwriting_attempts', attempt.toJson());

    // 2. Queue for sync
    await _enqueueSyncOperation(
      tableName: 'handwriting_attempts',
      recordId: attempt.id,
      operation: 'insert',
      payload: attempt.toJson(),
    );

    debugPrint(
      '✅ Handwriting attempt saved locally: ${attempt.targetCharacter} (${attempt.shapeSimilarity})',
    );
    return attempt;
  }

  /// Get all attempts for a specific child
  Future<List<HandwritingAttempt>> getAttemptsForChild(String childId) async {
    final results = await _db.query(
      'handwriting_attempts',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'created_at DESC',
    );

    return results.map((json) => HandwritingAttempt.fromJson(json)).toList();
  }

  /// Get all attempts (for analytics)
  Future<List<HandwritingAttempt>> getAllAttempts() async {
    final results = await _db.query(
      'handwriting_attempts',
      orderBy: 'created_at DESC',
    );

    return results.map((json) => HandwritingAttempt.fromJson(json)).toList();
  }

  // ==================== SYNC QUEUE ====================

  /// Enqueue an operation for cloud sync
  Future<void> _enqueueSyncOperation({
    required String tableName,
    required String recordId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final queueItem = SyncQueueItem(
      tableName: tableName,
      recordId: recordId,
      operation: operation,
      payload: jsonEncode(payload),
    );

    await _db.insert('sync_queue', queueItem.toJson());
    debugPrint('📤 Queued for sync: $tableName/$recordId');
  }

  /// Get all pending sync items
  Future<List<SyncQueueItem>> getPendingSyncItems() async {
    final results = await _db.query(
      'sync_queue',
      orderBy: 'created_at ASC',
    );

    return results.map((json) => SyncQueueItem.fromJson(json)).toList();
  }

  /// Remove a sync queue item (after successful sync)
  Future<void> removeSyncItem(String id) async {
    await _db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint('✅ Sync item removed: $id');
  }

  /// Clear all sync queue items (use with caution)
  Future<void> clearSyncQueue() async {
    await _db.delete('sync_queue');
    debugPrint('🗑️ Sync queue cleared');
  }

  // ==================== UTILITIES ====================

  /// Get database statistics (for debugging)
  Future<Map<String, int>> getStats() async {
    final childrenCount = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(*) FROM children'),
    );
    final attemptsCount = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(*) FROM handwriting_attempts'),
    );
    final queueCount = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(*) FROM sync_queue'),
    );

    return {
      'children': childrenCount ?? 0,
      'attempts': attemptsCount ?? 0,
      'pending_sync': queueCount ?? 0,
    };
  }

  /// Close the database (for testing)
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
