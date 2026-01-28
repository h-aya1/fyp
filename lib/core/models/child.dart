import 'package:uuid/uuid.dart';

/// Represents a child learner in the app.
/// 
/// Phase 1: No authentication - children are identified locally only.
/// UUIDs are generated client-side for offline-first operation.
class Child {
  /// Unique identifier (UUID) generated client-side
  final String id;

  /// Owner ID (Supabase Auth User ID) - Null if only local
  final String? ownerId;

  /// Child's nickname (optional, for personalization)
  final String? nickname;

  /// Timestamp when the child profile was created
  final DateTime createdAt;

  /// Timestamp when the child was claimed by a parent
  final DateTime? claimedAt;

  Child({
    String? id,
    this.ownerId,
    this.nickname,
    DateTime? createdAt,
    this.claimedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Creates a copy with optional field updates
  Child copyWith({
    String? id,
    String? ownerId,
    String? nickname,
    DateTime? createdAt,
    DateTime? claimedAt,
  }) {
    return Child(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt ?? this.createdAt,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  /// Convert to JSON for SQLite storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'nickname': nickname,
        'created_at': createdAt.toIso8601String(),
        'claimed_at': claimedAt?.toIso8601String(),
      };

  /// Create from JSON (SQLite or Supabase)
  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String?,
      nickname: json['nickname'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      claimedAt: json['claimed_at'] != null
          ? DateTime.parse(json['claimed_at'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'Child(id: $id, ownerId: $ownerId, nickname: $nickname, claimedAt: $claimedAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Child &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ownerId == other.ownerId &&
          nickname == other.nickname &&
          createdAt == other.createdAt &&
          claimedAt == other.claimedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      ownerId.hashCode ^
      nickname.hashCode ^
      createdAt.hashCode ^
      claimedAt.hashCode;
}
