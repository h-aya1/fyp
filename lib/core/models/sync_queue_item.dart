import 'package:uuid/uuid.dart';

/// Represents a queued sync operation for cloud backup.
/// 
/// Phase 1: Simple queue that stores operations to be synced when online.
/// This ensures the app works 100% offline with best-effort cloud backup.
class SyncQueueItem {
  /// Unique identifier for this queue item
  final String id;

  /// Table name: "children" or "handwriting_attempts"
  final String tableName;

  /// ID of the record to sync
  final String recordId;

  /// Operation type: "insert" or "update"
  final String operation;

  /// JSON payload of the record
  final String payload;

  /// When this item was queued
  final DateTime createdAt;

  SyncQueueItem({
    String? id,
    required this.tableName,
    required this.recordId,
    required this.operation,
    required this.payload,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON for SQLite storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'table_name': tableName,
        'record_id': recordId,
        'operation': operation,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
      };

  /// Create from JSON (SQLite)
  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      tableName: json['table_name'] as String,
      recordId: json['record_id'] as String,
      operation: json['operation'] as String,
      payload: json['payload'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  String toString() =>
      'SyncQueueItem(id: $id, table: $tableName, operation: $operation)';
}
