import 'package:drift/drift.dart';

/// Sync log table - tracks local changes for offline sync
class SyncLog extends Table {
  /// Auto-increment ID
  IntColumn get id => integer().autoIncrement()();

  /// Circle ID (for scoping)
  TextColumn get circleId => text()();

  /// Entity type: moment, letter, comment, etc.
  TextColumn get entityType => text()();

  /// Entity ID
  TextColumn get entityId => text()();

  /// Action: create, update, delete
  TextColumn get action => text()();

  /// Full entity data as JSON (for create/update)
  TextColumn get data => text().nullable()();

  /// When this change happened locally
  DateTimeColumn get timestamp => dateTime()();

  /// Number of sync attempts
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// Last error message if failed
  TextColumn get lastError => text().nullable()();

  /// Is this change synced
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  /// When it was synced
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

/// Sync status table - tracks overall sync state per circle
class SyncStatus extends Table {
  /// Circle ID
  TextColumn get circleId => text()();

  /// Last successful full sync timestamp
  DateTimeColumn get lastFullSync => dateTime().nullable()();

  /// Last successful incremental sync timestamp
  DateTimeColumn get lastIncrementalSync => dateTime().nullable()();

  /// Number of pending changes
  IntColumn get pendingChanges => integer().withDefault(const Constant(0))();

  /// Is currently syncing
  BoolColumn get isSyncing => boolean().withDefault(const Constant(false))();

  /// Last sync error
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {circleId};
}

/// Key-value store for app settings and metadata
class AppSettings extends Table {
  /// Setting key
  TextColumn get key => text()();

  /// Setting value (JSON or string)
  TextColumn get value => text()();

  /// When this setting was last updated
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
