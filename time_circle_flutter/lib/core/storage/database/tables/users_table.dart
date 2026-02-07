import 'package:drift/drift.dart';

/// Users table - stores user information
class Users extends Table {
  /// User ID (from server)
  TextColumn get id => text()();

  /// User email
  TextColumn get email => text()();

  /// User display name
  TextColumn get name => text()();

  /// Avatar URL
  TextColumn get avatar => text().nullable()();

  /// Role label in circle
  TextColumn get roleLabel => text().nullable()();

  /// When user joined the circle
  DateTimeColumn get joinedAt => dateTime().nullable()();

  /// Account creation time
  DateTimeColumn get createdAt => dateTime()();

  /// Last update time
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Local sync status
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Circles table - stores circle information
class Circles extends Table {
  /// Circle ID (from server)
  TextColumn get id => text()();

  /// Circle name
  TextColumn get name => text()();

  /// Circle start date (relationship start)
  DateTimeColumn get startDate => dateTime().nullable()();

  /// Invite code for joining
  TextColumn get inviteCode => text().nullable()();

  /// Invite code expiration
  DateTimeColumn get inviteExpiresAt => dateTime().nullable()();

  /// Who created this circle
  TextColumn get createdBy => text()();

  /// Current user's role in this circle
  TextColumn get role => text().nullable()();

  /// Current user's role label
  TextColumn get roleLabel => text().nullable()();

  /// When current user joined
  DateTimeColumn get joinedAt => dateTime().nullable()();

  /// Number of members
  IntColumn get memberCount => integer().withDefault(const Constant(0))();

  /// Number of moments
  IntColumn get momentCount => integer().withDefault(const Constant(0))();

  /// Number of letters
  IntColumn get letterCount => integer().withDefault(const Constant(0))();

  /// Creation time
  DateTimeColumn get createdAt => dateTime()();

  /// Last update time
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Sync status
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Circle members table - stores circle membership
class CircleMembers extends Table {
  /// Circle ID
  TextColumn get circleId => text().references(Circles, #id)();

  /// User ID
  TextColumn get userId => text().references(Users, #id)();

  /// Member role (admin/member)
  TextColumn get role => text()();

  /// Custom role label
  TextColumn get roleLabel => text().nullable()();

  /// When they joined
  DateTimeColumn get joinedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {circleId, userId};
}
