import 'package:drift/drift.dart';

import 'users_table.dart';

/// Moments table - stores timeline moments
class Moments extends Table {
  /// Moment ID (from server or local UUID)
  TextColumn get id => text()();

  /// Circle this moment belongs to
  TextColumn get circleId => text().references(Circles, #id)();

  /// Author user ID
  TextColumn get authorId => text().references(Users, #id)();

  /// Text content
  TextColumn get content => text()();

  /// Media type (text, image, video, audio)
  TextColumn get mediaType => text().withDefault(const Constant('text'))();

  /// Media URLs as JSON array string
  TextColumn get mediaUrls => text().withDefault(const Constant('[]'))();

  /// When the moment happened (can be different from creation time)
  DateTimeColumn get timestamp => dateTime()();

  /// Context tags as JSON object string
  TextColumn get contextTags => text().nullable()();

  /// Location string
  TextColumn get location => text().nullable()();

  /// Is this a favorite moment
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  /// Future message (time capsule note)
  TextColumn get futureMessage => text().nullable()();

  /// Is shared to world channel
  BoolColumn get isSharedToWorld =>
      boolean().withDefault(const Constant(false))();

  /// World channel topic if shared
  TextColumn get worldTopic => text().nullable()();

  /// Creation time
  DateTimeColumn get createdAt => dateTime()();

  /// Last update time
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Soft delete time
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Sync status: 0=synced, 1=pendingCreate, 2=pendingUpdate, 3=pendingDelete, 4=failed
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  /// Server version for conflict resolution
  IntColumn get serverVersion => integer().withDefault(const Constant(0))();

  /// Last sync attempt time
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Moment cache metadata for pagination
class MomentCacheInfo extends Table {
  /// Circle ID
  TextColumn get circleId => text()();

  /// Filter hash (to distinguish different filter combinations)
  TextColumn get filterHash => text()();

  /// Current page loaded
  IntColumn get currentPage => integer().withDefault(const Constant(1))();

  /// Total items on server
  IntColumn get totalItems => integer().withDefault(const Constant(0))();

  /// Has more pages
  BoolColumn get hasMore => boolean().withDefault(const Constant(true))();

  /// When this cache was last updated
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {circleId, filterHash};
}
