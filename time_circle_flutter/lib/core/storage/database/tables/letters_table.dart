import 'package:drift/drift.dart';

import 'users_table.dart';

/// Letters table - stores time capsule letters
class Letters extends Table {
  /// Letter ID (from server or local UUID)
  TextColumn get id => text()();

  /// Circle this letter belongs to
  TextColumn get circleId => text().references(Circles, #id)();

  /// Author user ID
  TextColumn get authorId => text().references(Users, #id)();

  /// Letter title
  TextColumn get title => text()();

  /// Preview text (first 100 chars)
  TextColumn get preview => text().withDefault(const Constant(''))();

  /// Full content (null if sealed and not yet unlocked)
  TextColumn get content => text().nullable()();

  /// Status: draft, sealed, unlocked
  TextColumn get status => text().withDefault(const Constant('draft'))();

  /// Type: annual, milestone, free
  TextColumn get type => text().withDefault(const Constant('free'))();

  /// Recipient name/description
  TextColumn get recipient => text()();

  /// When the letter can be unlocked
  DateTimeColumn get unlockDate => dateTime().nullable()();

  /// Creation time
  DateTimeColumn get createdAt => dateTime()();

  /// When the letter was sealed
  DateTimeColumn get sealedAt => dateTime().nullable()();

  /// Last update time
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Soft delete time
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Sync status: 0=synced, 1=pendingCreate, 2=pendingUpdate, 3=pendingDelete, 4=failed
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  /// Server version for conflict resolution
  IntColumn get serverVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
