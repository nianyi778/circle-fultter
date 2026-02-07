import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/tables.dart';
import 'daos/moments_dao.dart';
import 'daos/letters_dao.dart';

part 'app_database.g.dart';

/// Main application database using Drift
///
/// This database stores all offline-first data including:
/// - Users and circles
/// - Moments (timeline entries)
/// - Letters (time capsules)
/// - Sync logs for offline changes
@DriftDatabase(
  tables: [
    Users,
    Circles,
    CircleMembers,
    Moments,
    MomentCacheInfo,
    Letters,
    SyncLog,
    SyncStatus,
    AppSettings,
  ],
  daos: [MomentsDao, LettersDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Named constructor for testing with custom executor
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Create performance indexes
        await _createIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here when schema changes
        // Example:
        // if (from < 2) {
        //   await m.addColumn(moments, moments.someNewColumn);
        // }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
        // Enable WAL mode for better concurrent access
        await customStatement('PRAGMA journal_mode = WAL');
        // Set synchronous to NORMAL for better performance
        await customStatement('PRAGMA synchronous = NORMAL');
      },
    );
  }

  /// Create performance indexes for common queries
  Future<void> _createIndexes() async {
    // Moments indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_moments_circle_timestamp '
      'ON moments(circle_id, timestamp DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_moments_circle_author '
      'ON moments(circle_id, author_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_moments_sync_pending '
      'ON moments(sync_status) WHERE sync_status > 0',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_moments_favorite '
      'ON moments(circle_id, is_favorite) WHERE is_favorite = 1',
    );

    // Letters indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_letters_circle_status '
      'ON letters(circle_id, status)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_letters_unlock_date '
      'ON letters(unlock_date) WHERE status = \'sealed\'',
    );

    // Users/Circles indexes
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_circle_members_user '
      'ON circle_members(user_id)',
    );
  }

  // ============ User Operations ============

  /// Get or insert a user
  Future<User> getOrCreateUser(UsersCompanion user) async {
    final existing =
        await (select(users)
          ..where((u) => u.id.equals(user.id.value))).getSingleOrNull();

    if (existing != null) return existing;

    await into(users).insert(user);
    return (select(users)
      ..where((u) => u.id.equals(user.id.value))).getSingle();
  }

  /// Update user info
  Future<void> updateUser(UsersCompanion user) {
    return (update(users)
      ..where((u) => u.id.equals(user.id.value))).write(user);
  }

  /// Get user by ID
  Future<User?> getUserById(String id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  // ============ Circle Operations ============

  /// Get all circles for current user
  Future<List<Circle>> getUserCircles() {
    return (select(circles)
      ..orderBy([(c) => OrderingTerm.desc(c.joinedAt)])).get();
  }

  /// Get circle by ID
  Future<Circle?> getCircleById(String id) {
    return (select(circles)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Insert or update circle
  Future<void> upsertCircle(CirclesCompanion circle) {
    return into(circles).insertOnConflictUpdate(circle);
  }

  /// Insert or update multiple circles
  Future<void> upsertCircles(List<CirclesCompanion> circleList) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(circles, circleList);
    });
  }

  // ============ Sync Operations ============

  /// Log a sync event
  Future<void> logSyncEvent({
    required String circleId,
    required String entityType,
    required String entityId,
    required String action,
    String? data,
  }) {
    return into(syncLog).insert(
      SyncLogCompanion.insert(
        circleId: circleId,
        entityType: entityType,
        entityId: entityId,
        action: action,
        data: Value(data),
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Get pending sync events
  Future<List<SyncLogData>> getPendingSyncEvents(String circleId) {
    return (select(syncLog)
          ..where((s) => s.circleId.equals(circleId))
          ..where((s) => s.isSynced.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.timestamp)]))
        .get();
  }

  /// Mark sync event as synced
  Future<void> markSynced(int id) {
    return (update(syncLog)..where((s) => s.id.equals(id))).write(
      SyncLogCompanion(
        isSynced: const Value(true),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get sync status for a circle
  Future<SyncStatusData?> getSyncStatus(String circleId) {
    return (select(syncStatus)
      ..where((s) => s.circleId.equals(circleId))).getSingleOrNull();
  }

  /// Update sync status
  Future<void> updateSyncStatus(SyncStatusCompanion status) {
    return into(syncStatus).insertOnConflictUpdate(status);
  }

  // ============ Settings Operations ============

  /// Get a setting value
  Future<String?> getSetting(String key) async {
    final result =
        await (select(appSettings)
          ..where((s) => s.key.equals(key))).getSingleOrNull();
    return result?.value;
  }

  /// Set a setting value
  Future<void> setSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: Value(key),
        value: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete a setting
  Future<void> deleteSetting(String key) {
    return (delete(appSettings)..where((s) => s.key.equals(key))).go();
  }

  // ============ Cleanup Operations ============

  /// Clear all data for a circle
  Future<void> clearCircleData(String circleId) async {
    await (delete(moments)..where((m) => m.circleId.equals(circleId))).go();
    await (delete(letters)..where((l) => l.circleId.equals(circleId))).go();
    await (delete(syncLog)..where((s) => s.circleId.equals(circleId))).go();
    await (delete(syncStatus)..where((s) => s.circleId.equals(circleId))).go();
    await (delete(momentCacheInfo)
      ..where((c) => c.circleId.equals(circleId))).go();
  }

  /// Clear all database data (for logout)
  Future<void> clearAllData() async {
    await delete(moments).go();
    await delete(letters).go();
    await delete(circleMembers).go();
    await delete(circles).go();
    await delete(users).go();
    await delete(syncLog).go();
    await delete(syncStatus).go();
    await delete(momentCacheInfo).go();
    await delete(appSettings).go();
  }
}

/// Open database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aura.db'));
    return NativeDatabase.createInBackground(file);
  });
}
