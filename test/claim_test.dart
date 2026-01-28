import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fyp/core/services/persistence_service.dart';
import 'package:fyp/core/models/child.dart';

void main() {
  group('PersistenceService Claim Tests', () {
    late PersistenceService service;

    setUpAll(() {
      // Initialize FFI for desktop/test execution
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      service = PersistenceService();
      // Ensure specific test DB path or use in-memory if supported by the service logic
      // Since service uses getDatabasesPath(), we'll trust it works with FFI in test env.
      // We need to ensure we start fresh.
      await service.close();
      
      // We might need to delete the DB file to ensure fresh state, 
      // but getDatabasesPath behavior varies. 
      // For now, we'll try initializing and clearing tables.
      await service.initialize();
      
      // Clear tables
      final db = await openDatabase(await getDatabasesPath() + '/fidelkids.db');
      await db.delete('children');
      await db.delete('sync_queue');
      // We don't close this 'db' handle to keep connection open if needed or just use service
    });

    tearDown(() async {
      await service.close();
    });

    test('getUnclaimedChildrenCount returns correct count', () async {
      // Create 3 children
      await service.createChild(nickname: 'Alice');
      await service.createChild(nickname: 'Bob');
      await service.createChild(nickname: 'Charlie');

      final count = await service.getUnclaimedChildrenCount();
      expect(count, 3);
    });

    test('claimChildrenForParent updates owner_id and claimed_at', () async {
      // Arrange
      await service.createChild(nickname: 'Alice');
      await service.createChild(nickname: 'Bob');

      // Act
      const ownerId = 'parent-123';
      final claimedCount = await service.claimChildrenForParent(ownerId);

      // Assert
      expect(claimedCount, 2);

      final children = await service.getChildren();
      for (final child in children) {
        expect(child.ownerId, ownerId);
        expect(child.claimedAt, isNotNull);
        // Ensure queue items created
      }
      
      final unclaimedCount = await service.getUnclaimedChildrenCount();
      expect(unclaimedCount, 0);
    });

    test('claimChildrenForParent is idempotent (running twice does not break things)', () async {
       // Arrange
      await service.createChild(nickname: 'Alice');

      // Act 1
      const ownerId = 'parent-123';
      await service.claimChildrenForParent(ownerId);
      
      // Act 2
      final claimedCount2 = await service.claimChildrenForParent(ownerId);

      // Assert
      expect(claimedCount2, 0); // Should be 0 since they are already claimed
      
      final children = await service.getChildren();
      expect(children.length, 1);
      expect(children.first.ownerId, ownerId);
    });

    test('claimChildrenForParent does not affect already owned children', () async {
       // Arrange
      // Manually insert a child with an owner (simulate already claimed or created online)
      // Since createChild doesn't support ownerId arg in this version (it's local-first), 
      // we'll create then claim, then create another new one.
      
      await service.createChild(nickname: 'ClaimedChild');
      await service.claimChildrenForParent('owner-A');
      
      await service.createChild(nickname: 'NewUnclaimedChild');

      // Act
      final count = await service.claimChildrenForParent('owner-B');

      // Assert
      expect(count, 1); // Only the new one
      
      final children = await service.getChildren();
      final claimedChild = children.firstWhere((c) => c.nickname == 'ClaimedChild');
      final newChild = children.firstWhere((c) => c.nickname == 'NewUnclaimedChild');
      
      expect(claimedChild.ownerId, 'owner-A'); // Should NOT change
      expect(newChild.ownerId, 'owner-B'); // Should be claimed
    });
    
    test('claimChildrenForParent creates upload sync items', () async {
       await service.createChild(nickname: 'ToSync');
       await service.clearSyncQueue(); // Clear insert, focus on update
       
       await service.claimChildrenForParent('parent-x');
       
       final queue = await service.getPendingSyncItems();
       expect(queue.length, 1);
       expect(queue.first.operation, 'update');
       expect(queue.first.tableName, 'children');
    });
  });
}
