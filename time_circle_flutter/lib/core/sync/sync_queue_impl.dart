// 同步队列实现
//
// 使用内存存储，实际项目中应使用 Drift 数据库

import 'dart:async';
import 'sync_engine.dart';

/// 内存同步队列实现
///
/// TODO: 实际项目中应替换为 Drift 数据库实现
class SyncQueueImpl implements SyncQueue {
  final Map<String, SyncItem> _items = {};

  @override
  Future<void> enqueue(SyncItem item) async {
    _items[item.id] = item;
  }

  @override
  Future<List<SyncItem>> getPendingItems() async {
    return _items.values
        .where(
          (item) =>
              item.status == SyncItemStatus.pending ||
              item.status == SyncItemStatus.failed,
        )
        .toList();
  }

  @override
  Future<void> markAsSynced(String id) async {
    if (_items.containsKey(id)) {
      _items[id] = _items[id]!.copyWith(status: SyncItemStatus.synced);
    }
  }

  @override
  Future<void> incrementRetryCount(String id) async {
    if (_items.containsKey(id)) {
      final item = _items[id]!;
      _items[id] = item.copyWith(
        retryCount: item.retryCount + 1,
        status: SyncItemStatus.failed,
      );
    }
  }

  @override
  Future<void> remove(String id) async {
    _items.remove(id);
  }

  @override
  Future<void> clear() async {
    _items.clear();
  }
}

/// Drift 数据库同步队列实现（框架）
///
/// 在使用 Drift 时替换 SyncQueueImpl
class DriftSyncQueue implements SyncQueue {
  // final AppDatabase _db;

  // DriftSyncQueue(this._db);

  @override
  Future<void> enqueue(SyncItem item) async {
    // await _db.into(_db.syncQueue).insert(
    //   SyncQueueCompanion.insert(
    //     entityType: item.entityType,
    //     entityId: item.entityId,
    //     action: item.action.name,
    //     data: jsonEncode(item.data),
    //     clientTimestamp: item.clientTimestamp,
    //   ),
    // );
    throw UnimplementedError();
  }

  @override
  Future<List<SyncItem>> getPendingItems() async {
    // final items = await (_db.select(_db.syncQueue)
    //   ..where((t) => t.status.equals(SyncItemStatus.pending.index) |
    //                  t.status.equals(SyncItemStatus.failed.index)))
    //   .get();
    // return items.map((e) => _mapToSyncItem(e)).toList();
    throw UnimplementedError();
  }

  @override
  Future<void> markAsSynced(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> incrementRetryCount(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> remove(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> clear() async {
    throw UnimplementedError();
  }
}
