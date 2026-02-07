// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleLabelMeta = const VerificationMeta(
    'roleLabel',
  );
  @override
  late final GeneratedColumn<String> roleLabel = GeneratedColumn<String>(
    'role_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    name,
    avatar,
    roleLabel,
    joinedAt,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('role_label')) {
      context.handle(
        _roleLabelMeta,
        roleLabel.isAcceptableOrUnknown(data['role_label']!, _roleLabelMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      email:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}email'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      roleLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_label'],
      ),
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sync_status'],
          )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  /// User ID (from server)
  final String id;

  /// User email
  final String email;

  /// User display name
  final String name;

  /// Avatar URL
  final String? avatar;

  /// Role label in circle
  final String? roleLabel;

  /// When user joined the circle
  final DateTime? joinedAt;

  /// Account creation time
  final DateTime createdAt;

  /// Last update time
  final DateTime? updatedAt;

  /// Local sync status
  final int syncStatus;
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.roleLabel,
    this.joinedAt,
    required this.createdAt,
    this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    if (!nullToAbsent || roleLabel != null) {
      map['role_label'] = Variable<String>(roleLabel);
    }
    if (!nullToAbsent || joinedAt != null) {
      map['joined_at'] = Variable<DateTime>(joinedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['sync_status'] = Variable<int>(syncStatus);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      name: Value(name),
      avatar:
          avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      roleLabel:
          roleLabel == null && nullToAbsent
              ? const Value.absent()
              : Value(roleLabel),
      joinedAt:
          joinedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(joinedAt),
      createdAt: Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      name: serializer.fromJson<String>(json['name']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      roleLabel: serializer.fromJson<String?>(json['roleLabel']),
      joinedAt: serializer.fromJson<DateTime?>(json['joinedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String>(name),
      'avatar': serializer.toJson<String?>(avatar),
      'roleLabel': serializer.toJson<String?>(roleLabel),
      'joinedAt': serializer.toJson<DateTime?>(joinedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'syncStatus': serializer.toJson<int>(syncStatus),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    Value<String?> avatar = const Value.absent(),
    Value<String?> roleLabel = const Value.absent(),
    Value<DateTime?> joinedAt = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    int? syncStatus,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    avatar: avatar.present ? avatar.value : this.avatar,
    roleLabel: roleLabel.present ? roleLabel.value : this.roleLabel,
    joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      roleLabel: data.roleLabel.present ? data.roleLabel.value : this.roleLabel,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('roleLabel: $roleLabel, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    name,
    avatar,
    roleLabel,
    joinedAt,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.name == this.name &&
          other.avatar == this.avatar &&
          other.roleLabel == this.roleLabel &&
          other.joinedAt == this.joinedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> name;
  final Value<String?> avatar;
  final Value<String?> roleLabel;
  final Value<DateTime?> joinedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> syncStatus;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
    this.roleLabel = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String name,
    this.avatar = const Value.absent(),
    this.roleLabel = const Value.absent(),
    this.joinedAt = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? name,
    Expression<String>? avatar,
    Expression<String>? roleLabel,
    Expression<DateTime>? joinedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (roleLabel != null) 'role_label': roleLabel,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? name,
    Value<String?>? avatar,
    Value<String?>? roleLabel,
    Value<DateTime?>? joinedAt,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? syncStatus,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      roleLabel: roleLabel ?? this.roleLabel,
      joinedAt: joinedAt ?? this.joinedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (roleLabel.present) {
      map['role_label'] = Variable<String>(roleLabel.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('roleLabel: $roleLabel, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CirclesTable extends Circles with TableInfo<$CirclesTable, Circle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CirclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inviteCodeMeta = const VerificationMeta(
    'inviteCode',
  );
  @override
  late final GeneratedColumn<String> inviteCode = GeneratedColumn<String>(
    'invite_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inviteExpiresAtMeta = const VerificationMeta(
    'inviteExpiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> inviteExpiresAt =
      GeneratedColumn<DateTime>(
        'invite_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleLabelMeta = const VerificationMeta(
    'roleLabel',
  );
  @override
  late final GeneratedColumn<String> roleLabel = GeneratedColumn<String>(
    'role_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memberCountMeta = const VerificationMeta(
    'memberCount',
  );
  @override
  late final GeneratedColumn<int> memberCount = GeneratedColumn<int>(
    'member_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _momentCountMeta = const VerificationMeta(
    'momentCount',
  );
  @override
  late final GeneratedColumn<int> momentCount = GeneratedColumn<int>(
    'moment_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _letterCountMeta = const VerificationMeta(
    'letterCount',
  );
  @override
  late final GeneratedColumn<int> letterCount = GeneratedColumn<int>(
    'letter_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    startDate,
    inviteCode,
    inviteExpiresAt,
    createdBy,
    role,
    roleLabel,
    joinedAt,
    memberCount,
    momentCount,
    letterCount,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'circles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Circle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('invite_code')) {
      context.handle(
        _inviteCodeMeta,
        inviteCode.isAcceptableOrUnknown(data['invite_code']!, _inviteCodeMeta),
      );
    }
    if (data.containsKey('invite_expires_at')) {
      context.handle(
        _inviteExpiresAtMeta,
        inviteExpiresAt.isAcceptableOrUnknown(
          data['invite_expires_at']!,
          _inviteExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('role_label')) {
      context.handle(
        _roleLabelMeta,
        roleLabel.isAcceptableOrUnknown(data['role_label']!, _roleLabelMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    if (data.containsKey('member_count')) {
      context.handle(
        _memberCountMeta,
        memberCount.isAcceptableOrUnknown(
          data['member_count']!,
          _memberCountMeta,
        ),
      );
    }
    if (data.containsKey('moment_count')) {
      context.handle(
        _momentCountMeta,
        momentCount.isAcceptableOrUnknown(
          data['moment_count']!,
          _momentCountMeta,
        ),
      );
    }
    if (data.containsKey('letter_count')) {
      context.handle(
        _letterCountMeta,
        letterCount.isAcceptableOrUnknown(
          data['letter_count']!,
          _letterCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Circle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Circle(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      inviteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invite_code'],
      ),
      inviteExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invite_expires_at'],
      ),
      createdBy:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}created_by'],
          )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      roleLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_label'],
      ),
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      ),
      memberCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}member_count'],
          )!,
      momentCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}moment_count'],
          )!,
      letterCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}letter_count'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sync_status'],
          )!,
    );
  }

  @override
  $CirclesTable createAlias(String alias) {
    return $CirclesTable(attachedDatabase, alias);
  }
}

class Circle extends DataClass implements Insertable<Circle> {
  /// Circle ID (from server)
  final String id;

  /// Circle name
  final String name;

  /// Circle start date (relationship start)
  final DateTime? startDate;

  /// Invite code for joining
  final String? inviteCode;

  /// Invite code expiration
  final DateTime? inviteExpiresAt;

  /// Who created this circle
  final String createdBy;

  /// Current user's role in this circle
  final String? role;

  /// Current user's role label
  final String? roleLabel;

  /// When current user joined
  final DateTime? joinedAt;

  /// Number of members
  final int memberCount;

  /// Number of moments
  final int momentCount;

  /// Number of letters
  final int letterCount;

  /// Creation time
  final DateTime createdAt;

  /// Last update time
  final DateTime? updatedAt;

  /// Sync status
  final int syncStatus;
  const Circle({
    required this.id,
    required this.name,
    this.startDate,
    this.inviteCode,
    this.inviteExpiresAt,
    required this.createdBy,
    this.role,
    this.roleLabel,
    this.joinedAt,
    required this.memberCount,
    required this.momentCount,
    required this.letterCount,
    required this.createdAt,
    this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || inviteCode != null) {
      map['invite_code'] = Variable<String>(inviteCode);
    }
    if (!nullToAbsent || inviteExpiresAt != null) {
      map['invite_expires_at'] = Variable<DateTime>(inviteExpiresAt);
    }
    map['created_by'] = Variable<String>(createdBy);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || roleLabel != null) {
      map['role_label'] = Variable<String>(roleLabel);
    }
    if (!nullToAbsent || joinedAt != null) {
      map['joined_at'] = Variable<DateTime>(joinedAt);
    }
    map['member_count'] = Variable<int>(memberCount);
    map['moment_count'] = Variable<int>(momentCount);
    map['letter_count'] = Variable<int>(letterCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['sync_status'] = Variable<int>(syncStatus);
    return map;
  }

  CirclesCompanion toCompanion(bool nullToAbsent) {
    return CirclesCompanion(
      id: Value(id),
      name: Value(name),
      startDate:
          startDate == null && nullToAbsent
              ? const Value.absent()
              : Value(startDate),
      inviteCode:
          inviteCode == null && nullToAbsent
              ? const Value.absent()
              : Value(inviteCode),
      inviteExpiresAt:
          inviteExpiresAt == null && nullToAbsent
              ? const Value.absent()
              : Value(inviteExpiresAt),
      createdBy: Value(createdBy),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      roleLabel:
          roleLabel == null && nullToAbsent
              ? const Value.absent()
              : Value(roleLabel),
      joinedAt:
          joinedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(joinedAt),
      memberCount: Value(memberCount),
      momentCount: Value(momentCount),
      letterCount: Value(letterCount),
      createdAt: Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Circle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Circle(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      inviteCode: serializer.fromJson<String?>(json['inviteCode']),
      inviteExpiresAt: serializer.fromJson<DateTime?>(json['inviteExpiresAt']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      role: serializer.fromJson<String?>(json['role']),
      roleLabel: serializer.fromJson<String?>(json['roleLabel']),
      joinedAt: serializer.fromJson<DateTime?>(json['joinedAt']),
      memberCount: serializer.fromJson<int>(json['memberCount']),
      momentCount: serializer.fromJson<int>(json['momentCount']),
      letterCount: serializer.fromJson<int>(json['letterCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'inviteCode': serializer.toJson<String?>(inviteCode),
      'inviteExpiresAt': serializer.toJson<DateTime?>(inviteExpiresAt),
      'createdBy': serializer.toJson<String>(createdBy),
      'role': serializer.toJson<String?>(role),
      'roleLabel': serializer.toJson<String?>(roleLabel),
      'joinedAt': serializer.toJson<DateTime?>(joinedAt),
      'memberCount': serializer.toJson<int>(memberCount),
      'momentCount': serializer.toJson<int>(momentCount),
      'letterCount': serializer.toJson<int>(letterCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'syncStatus': serializer.toJson<int>(syncStatus),
    };
  }

  Circle copyWith({
    String? id,
    String? name,
    Value<DateTime?> startDate = const Value.absent(),
    Value<String?> inviteCode = const Value.absent(),
    Value<DateTime?> inviteExpiresAt = const Value.absent(),
    String? createdBy,
    Value<String?> role = const Value.absent(),
    Value<String?> roleLabel = const Value.absent(),
    Value<DateTime?> joinedAt = const Value.absent(),
    int? memberCount,
    int? momentCount,
    int? letterCount,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    int? syncStatus,
  }) => Circle(
    id: id ?? this.id,
    name: name ?? this.name,
    startDate: startDate.present ? startDate.value : this.startDate,
    inviteCode: inviteCode.present ? inviteCode.value : this.inviteCode,
    inviteExpiresAt:
        inviteExpiresAt.present ? inviteExpiresAt.value : this.inviteExpiresAt,
    createdBy: createdBy ?? this.createdBy,
    role: role.present ? role.value : this.role,
    roleLabel: roleLabel.present ? roleLabel.value : this.roleLabel,
    joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
    memberCount: memberCount ?? this.memberCount,
    momentCount: momentCount ?? this.momentCount,
    letterCount: letterCount ?? this.letterCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Circle copyWithCompanion(CirclesCompanion data) {
    return Circle(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      inviteCode:
          data.inviteCode.present ? data.inviteCode.value : this.inviteCode,
      inviteExpiresAt:
          data.inviteExpiresAt.present
              ? data.inviteExpiresAt.value
              : this.inviteExpiresAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      role: data.role.present ? data.role.value : this.role,
      roleLabel: data.roleLabel.present ? data.roleLabel.value : this.roleLabel,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      memberCount:
          data.memberCount.present ? data.memberCount.value : this.memberCount,
      momentCount:
          data.momentCount.present ? data.momentCount.value : this.momentCount,
      letterCount:
          data.letterCount.present ? data.letterCount.value : this.letterCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Circle(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('inviteExpiresAt: $inviteExpiresAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('role: $role, ')
          ..write('roleLabel: $roleLabel, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('memberCount: $memberCount, ')
          ..write('momentCount: $momentCount, ')
          ..write('letterCount: $letterCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    startDate,
    inviteCode,
    inviteExpiresAt,
    createdBy,
    role,
    roleLabel,
    joinedAt,
    memberCount,
    momentCount,
    letterCount,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Circle &&
          other.id == this.id &&
          other.name == this.name &&
          other.startDate == this.startDate &&
          other.inviteCode == this.inviteCode &&
          other.inviteExpiresAt == this.inviteExpiresAt &&
          other.createdBy == this.createdBy &&
          other.role == this.role &&
          other.roleLabel == this.roleLabel &&
          other.joinedAt == this.joinedAt &&
          other.memberCount == this.memberCount &&
          other.momentCount == this.momentCount &&
          other.letterCount == this.letterCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class CirclesCompanion extends UpdateCompanion<Circle> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime?> startDate;
  final Value<String?> inviteCode;
  final Value<DateTime?> inviteExpiresAt;
  final Value<String> createdBy;
  final Value<String?> role;
  final Value<String?> roleLabel;
  final Value<DateTime?> joinedAt;
  final Value<int> memberCount;
  final Value<int> momentCount;
  final Value<int> letterCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> syncStatus;
  final Value<int> rowid;
  const CirclesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startDate = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.inviteExpiresAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.role = const Value.absent(),
    this.roleLabel = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.momentCount = const Value.absent(),
    this.letterCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CirclesCompanion.insert({
    required String id,
    required String name,
    this.startDate = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.inviteExpiresAt = const Value.absent(),
    required String createdBy,
    this.role = const Value.absent(),
    this.roleLabel = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.momentCount = const Value.absent(),
    this.letterCount = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdBy = Value(createdBy),
       createdAt = Value(createdAt);
  static Insertable<Circle> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? startDate,
    Expression<String>? inviteCode,
    Expression<DateTime>? inviteExpiresAt,
    Expression<String>? createdBy,
    Expression<String>? role,
    Expression<String>? roleLabel,
    Expression<DateTime>? joinedAt,
    Expression<int>? memberCount,
    Expression<int>? momentCount,
    Expression<int>? letterCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startDate != null) 'start_date': startDate,
      if (inviteCode != null) 'invite_code': inviteCode,
      if (inviteExpiresAt != null) 'invite_expires_at': inviteExpiresAt,
      if (createdBy != null) 'created_by': createdBy,
      if (role != null) 'role': role,
      if (roleLabel != null) 'role_label': roleLabel,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (memberCount != null) 'member_count': memberCount,
      if (momentCount != null) 'moment_count': momentCount,
      if (letterCount != null) 'letter_count': letterCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CirclesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime?>? startDate,
    Value<String?>? inviteCode,
    Value<DateTime?>? inviteExpiresAt,
    Value<String>? createdBy,
    Value<String?>? role,
    Value<String?>? roleLabel,
    Value<DateTime?>? joinedAt,
    Value<int>? memberCount,
    Value<int>? momentCount,
    Value<int>? letterCount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? syncStatus,
    Value<int>? rowid,
  }) {
    return CirclesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      inviteCode: inviteCode ?? this.inviteCode,
      inviteExpiresAt: inviteExpiresAt ?? this.inviteExpiresAt,
      createdBy: createdBy ?? this.createdBy,
      role: role ?? this.role,
      roleLabel: roleLabel ?? this.roleLabel,
      joinedAt: joinedAt ?? this.joinedAt,
      memberCount: memberCount ?? this.memberCount,
      momentCount: momentCount ?? this.momentCount,
      letterCount: letterCount ?? this.letterCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (inviteCode.present) {
      map['invite_code'] = Variable<String>(inviteCode.value);
    }
    if (inviteExpiresAt.present) {
      map['invite_expires_at'] = Variable<DateTime>(inviteExpiresAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (roleLabel.present) {
      map['role_label'] = Variable<String>(roleLabel.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (memberCount.present) {
      map['member_count'] = Variable<int>(memberCount.value);
    }
    if (momentCount.present) {
      map['moment_count'] = Variable<int>(momentCount.value);
    }
    if (letterCount.present) {
      map['letter_count'] = Variable<int>(letterCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CirclesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('inviteExpiresAt: $inviteExpiresAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('role: $role, ')
          ..write('roleLabel: $roleLabel, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('memberCount: $memberCount, ')
          ..write('momentCount: $momentCount, ')
          ..write('letterCount: $letterCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CircleMembersTable extends CircleMembers
    with TableInfo<$CircleMembersTable, CircleMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CircleMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _circleIdMeta = const VerificationMeta(
    'circleId',
  );
  @override
  late final GeneratedColumn<String> circleId = GeneratedColumn<String>(
    'circle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES circles (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleLabelMeta = const VerificationMeta(
    'roleLabel',
  );
  @override
  late final GeneratedColumn<String> roleLabel = GeneratedColumn<String>(
    'role_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    circleId,
    userId,
    role,
    roleLabel,
    joinedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'circle_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<CircleMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('circle_id')) {
      context.handle(
        _circleIdMeta,
        circleId.isAcceptableOrUnknown(data['circle_id']!, _circleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circleIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('role_label')) {
      context.handle(
        _roleLabelMeta,
        roleLabel.isAcceptableOrUnknown(data['role_label']!, _roleLabelMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {circleId, userId};
  @override
  CircleMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CircleMember(
      circleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}circle_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      role:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}role'],
          )!,
      roleLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_label'],
      ),
      joinedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}joined_at'],
          )!,
    );
  }

  @override
  $CircleMembersTable createAlias(String alias) {
    return $CircleMembersTable(attachedDatabase, alias);
  }
}

class CircleMember extends DataClass implements Insertable<CircleMember> {
  /// Circle ID
  final String circleId;

  /// User ID
  final String userId;

  /// Member role (admin/member)
  final String role;

  /// Custom role label
  final String? roleLabel;

  /// When they joined
  final DateTime joinedAt;
  const CircleMember({
    required this.circleId,
    required this.userId,
    required this.role,
    this.roleLabel,
    required this.joinedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['circle_id'] = Variable<String>(circleId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || roleLabel != null) {
      map['role_label'] = Variable<String>(roleLabel);
    }
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  CircleMembersCompanion toCompanion(bool nullToAbsent) {
    return CircleMembersCompanion(
      circleId: Value(circleId),
      userId: Value(userId),
      role: Value(role),
      roleLabel:
          roleLabel == null && nullToAbsent
              ? const Value.absent()
              : Value(roleLabel),
      joinedAt: Value(joinedAt),
    );
  }

  factory CircleMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CircleMember(
      circleId: serializer.fromJson<String>(json['circleId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      roleLabel: serializer.fromJson<String?>(json['roleLabel']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'circleId': serializer.toJson<String>(circleId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'roleLabel': serializer.toJson<String?>(roleLabel),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  CircleMember copyWith({
    String? circleId,
    String? userId,
    String? role,
    Value<String?> roleLabel = const Value.absent(),
    DateTime? joinedAt,
  }) => CircleMember(
    circleId: circleId ?? this.circleId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    roleLabel: roleLabel.present ? roleLabel.value : this.roleLabel,
    joinedAt: joinedAt ?? this.joinedAt,
  );
  CircleMember copyWithCompanion(CircleMembersCompanion data) {
    return CircleMember(
      circleId: data.circleId.present ? data.circleId.value : this.circleId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      roleLabel: data.roleLabel.present ? data.roleLabel.value : this.roleLabel,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CircleMember(')
          ..write('circleId: $circleId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('roleLabel: $roleLabel, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(circleId, userId, role, roleLabel, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CircleMember &&
          other.circleId == this.circleId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.roleLabel == this.roleLabel &&
          other.joinedAt == this.joinedAt);
}

class CircleMembersCompanion extends UpdateCompanion<CircleMember> {
  final Value<String> circleId;
  final Value<String> userId;
  final Value<String> role;
  final Value<String?> roleLabel;
  final Value<DateTime> joinedAt;
  final Value<int> rowid;
  const CircleMembersCompanion({
    this.circleId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.roleLabel = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CircleMembersCompanion.insert({
    required String circleId,
    required String userId,
    required String role,
    this.roleLabel = const Value.absent(),
    required DateTime joinedAt,
    this.rowid = const Value.absent(),
  }) : circleId = Value(circleId),
       userId = Value(userId),
       role = Value(role),
       joinedAt = Value(joinedAt);
  static Insertable<CircleMember> custom({
    Expression<String>? circleId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<String>? roleLabel,
    Expression<DateTime>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (circleId != null) 'circle_id': circleId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (roleLabel != null) 'role_label': roleLabel,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CircleMembersCompanion copyWith({
    Value<String>? circleId,
    Value<String>? userId,
    Value<String>? role,
    Value<String?>? roleLabel,
    Value<DateTime>? joinedAt,
    Value<int>? rowid,
  }) {
    return CircleMembersCompanion(
      circleId: circleId ?? this.circleId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      roleLabel: roleLabel ?? this.roleLabel,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (circleId.present) {
      map['circle_id'] = Variable<String>(circleId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (roleLabel.present) {
      map['role_label'] = Variable<String>(roleLabel.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CircleMembersCompanion(')
          ..write('circleId: $circleId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('roleLabel: $roleLabel, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MomentsTable extends Moments with TableInfo<$MomentsTable, Moment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MomentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _circleIdMeta = const VerificationMeta(
    'circleId',
  );
  @override
  late final GeneratedColumn<String> circleId = GeneratedColumn<String>(
    'circle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES circles (id)',
    ),
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _mediaUrlsMeta = const VerificationMeta(
    'mediaUrls',
  );
  @override
  late final GeneratedColumn<String> mediaUrls = GeneratedColumn<String>(
    'media_urls',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextTagsMeta = const VerificationMeta(
    'contextTags',
  );
  @override
  late final GeneratedColumn<String> contextTags = GeneratedColumn<String>(
    'context_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _futureMessageMeta = const VerificationMeta(
    'futureMessage',
  );
  @override
  late final GeneratedColumn<String> futureMessage = GeneratedColumn<String>(
    'future_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSharedToWorldMeta = const VerificationMeta(
    'isSharedToWorld',
  );
  @override
  late final GeneratedColumn<bool> isSharedToWorld = GeneratedColumn<bool>(
    'is_shared_to_world',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared_to_world" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _worldTopicMeta = const VerificationMeta(
    'worldTopic',
  );
  @override
  late final GeneratedColumn<String> worldTopic = GeneratedColumn<String>(
    'world_topic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    circleId,
    authorId,
    content,
    mediaType,
    mediaUrls,
    timestamp,
    contextTags,
    location,
    isFavorite,
    futureMessage,
    isSharedToWorld,
    worldTopic,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    serverVersion,
    lastSyncAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'moments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Moment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('circle_id')) {
      context.handle(
        _circleIdMeta,
        circleId.isAcceptableOrUnknown(data['circle_id']!, _circleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circleIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    }
    if (data.containsKey('media_urls')) {
      context.handle(
        _mediaUrlsMeta,
        mediaUrls.isAcceptableOrUnknown(data['media_urls']!, _mediaUrlsMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('context_tags')) {
      context.handle(
        _contextTagsMeta,
        contextTags.isAcceptableOrUnknown(
          data['context_tags']!,
          _contextTagsMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('future_message')) {
      context.handle(
        _futureMessageMeta,
        futureMessage.isAcceptableOrUnknown(
          data['future_message']!,
          _futureMessageMeta,
        ),
      );
    }
    if (data.containsKey('is_shared_to_world')) {
      context.handle(
        _isSharedToWorldMeta,
        isSharedToWorld.isAcceptableOrUnknown(
          data['is_shared_to_world']!,
          _isSharedToWorldMeta,
        ),
      );
    }
    if (data.containsKey('world_topic')) {
      context.handle(
        _worldTopicMeta,
        worldTopic.isAcceptableOrUnknown(data['world_topic']!, _worldTopicMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Moment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Moment(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      circleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}circle_id'],
          )!,
      authorId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}author_id'],
          )!,
      content:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content'],
          )!,
      mediaType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}media_type'],
          )!,
      mediaUrls:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}media_urls'],
          )!,
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
      contextTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_tags'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      isFavorite:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_favorite'],
          )!,
      futureMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}future_message'],
      ),
      isSharedToWorld:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_shared_to_world'],
          )!,
      worldTopic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}world_topic'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sync_status'],
          )!,
      serverVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}server_version'],
          )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
    );
  }

  @override
  $MomentsTable createAlias(String alias) {
    return $MomentsTable(attachedDatabase, alias);
  }
}

class Moment extends DataClass implements Insertable<Moment> {
  /// Moment ID (from server or local UUID)
  final String id;

  /// Circle this moment belongs to
  final String circleId;

  /// Author user ID
  final String authorId;

  /// Text content
  final String content;

  /// Media type (text, image, video, audio)
  final String mediaType;

  /// Media URLs as JSON array string
  final String mediaUrls;

  /// When the moment happened (can be different from creation time)
  final DateTime timestamp;

  /// Context tags as JSON object string
  final String? contextTags;

  /// Location string
  final String? location;

  /// Is this a favorite moment
  final bool isFavorite;

  /// Future message (time capsule note)
  final String? futureMessage;

  /// Is shared to world channel
  final bool isSharedToWorld;

  /// World channel topic if shared
  final String? worldTopic;

  /// Creation time
  final DateTime createdAt;

  /// Last update time
  final DateTime? updatedAt;

  /// Soft delete time
  final DateTime? deletedAt;

  /// Sync status: 0=synced, 1=pendingCreate, 2=pendingUpdate, 3=pendingDelete, 4=failed
  final int syncStatus;

  /// Server version for conflict resolution
  final int serverVersion;

  /// Last sync attempt time
  final DateTime? lastSyncAt;
  const Moment({
    required this.id,
    required this.circleId,
    required this.authorId,
    required this.content,
    required this.mediaType,
    required this.mediaUrls,
    required this.timestamp,
    this.contextTags,
    this.location,
    required this.isFavorite,
    this.futureMessage,
    required this.isSharedToWorld,
    this.worldTopic,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.serverVersion,
    this.lastSyncAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['circle_id'] = Variable<String>(circleId);
    map['author_id'] = Variable<String>(authorId);
    map['content'] = Variable<String>(content);
    map['media_type'] = Variable<String>(mediaType);
    map['media_urls'] = Variable<String>(mediaUrls);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || contextTags != null) {
      map['context_tags'] = Variable<String>(contextTags);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || futureMessage != null) {
      map['future_message'] = Variable<String>(futureMessage);
    }
    map['is_shared_to_world'] = Variable<bool>(isSharedToWorld);
    if (!nullToAbsent || worldTopic != null) {
      map['world_topic'] = Variable<String>(worldTopic);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<int>(syncStatus);
    map['server_version'] = Variable<int>(serverVersion);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    return map;
  }

  MomentsCompanion toCompanion(bool nullToAbsent) {
    return MomentsCompanion(
      id: Value(id),
      circleId: Value(circleId),
      authorId: Value(authorId),
      content: Value(content),
      mediaType: Value(mediaType),
      mediaUrls: Value(mediaUrls),
      timestamp: Value(timestamp),
      contextTags:
          contextTags == null && nullToAbsent
              ? const Value.absent()
              : Value(contextTags),
      location:
          location == null && nullToAbsent
              ? const Value.absent()
              : Value(location),
      isFavorite: Value(isFavorite),
      futureMessage:
          futureMessage == null && nullToAbsent
              ? const Value.absent()
              : Value(futureMessage),
      isSharedToWorld: Value(isSharedToWorld),
      worldTopic:
          worldTopic == null && nullToAbsent
              ? const Value.absent()
              : Value(worldTopic),
      createdAt: Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      syncStatus: Value(syncStatus),
      serverVersion: Value(serverVersion),
      lastSyncAt:
          lastSyncAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSyncAt),
    );
  }

  factory Moment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Moment(
      id: serializer.fromJson<String>(json['id']),
      circleId: serializer.fromJson<String>(json['circleId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      content: serializer.fromJson<String>(json['content']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      mediaUrls: serializer.fromJson<String>(json['mediaUrls']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      contextTags: serializer.fromJson<String?>(json['contextTags']),
      location: serializer.fromJson<String?>(json['location']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      futureMessage: serializer.fromJson<String?>(json['futureMessage']),
      isSharedToWorld: serializer.fromJson<bool>(json['isSharedToWorld']),
      worldTopic: serializer.fromJson<String?>(json['worldTopic']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
      serverVersion: serializer.fromJson<int>(json['serverVersion']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'circleId': serializer.toJson<String>(circleId),
      'authorId': serializer.toJson<String>(authorId),
      'content': serializer.toJson<String>(content),
      'mediaType': serializer.toJson<String>(mediaType),
      'mediaUrls': serializer.toJson<String>(mediaUrls),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'contextTags': serializer.toJson<String?>(contextTags),
      'location': serializer.toJson<String?>(location),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'futureMessage': serializer.toJson<String?>(futureMessage),
      'isSharedToWorld': serializer.toJson<bool>(isSharedToWorld),
      'worldTopic': serializer.toJson<String?>(worldTopic),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<int>(syncStatus),
      'serverVersion': serializer.toJson<int>(serverVersion),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
    };
  }

  Moment copyWith({
    String? id,
    String? circleId,
    String? authorId,
    String? content,
    String? mediaType,
    String? mediaUrls,
    DateTime? timestamp,
    Value<String?> contextTags = const Value.absent(),
    Value<String?> location = const Value.absent(),
    bool? isFavorite,
    Value<String?> futureMessage = const Value.absent(),
    bool? isSharedToWorld,
    Value<String?> worldTopic = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncStatus,
    int? serverVersion,
    Value<DateTime?> lastSyncAt = const Value.absent(),
  }) => Moment(
    id: id ?? this.id,
    circleId: circleId ?? this.circleId,
    authorId: authorId ?? this.authorId,
    content: content ?? this.content,
    mediaType: mediaType ?? this.mediaType,
    mediaUrls: mediaUrls ?? this.mediaUrls,
    timestamp: timestamp ?? this.timestamp,
    contextTags: contextTags.present ? contextTags.value : this.contextTags,
    location: location.present ? location.value : this.location,
    isFavorite: isFavorite ?? this.isFavorite,
    futureMessage:
        futureMessage.present ? futureMessage.value : this.futureMessage,
    isSharedToWorld: isSharedToWorld ?? this.isSharedToWorld,
    worldTopic: worldTopic.present ? worldTopic.value : this.worldTopic,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    serverVersion: serverVersion ?? this.serverVersion,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
  );
  Moment copyWithCompanion(MomentsCompanion data) {
    return Moment(
      id: data.id.present ? data.id.value : this.id,
      circleId: data.circleId.present ? data.circleId.value : this.circleId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      content: data.content.present ? data.content.value : this.content,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      mediaUrls: data.mediaUrls.present ? data.mediaUrls.value : this.mediaUrls,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      contextTags:
          data.contextTags.present ? data.contextTags.value : this.contextTags,
      location: data.location.present ? data.location.value : this.location,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      futureMessage:
          data.futureMessage.present
              ? data.futureMessage.value
              : this.futureMessage,
      isSharedToWorld:
          data.isSharedToWorld.present
              ? data.isSharedToWorld.value
              : this.isSharedToWorld,
      worldTopic:
          data.worldTopic.present ? data.worldTopic.value : this.worldTopic,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      serverVersion:
          data.serverVersion.present
              ? data.serverVersion.value
              : this.serverVersion,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Moment(')
          ..write('id: $id, ')
          ..write('circleId: $circleId, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('mediaType: $mediaType, ')
          ..write('mediaUrls: $mediaUrls, ')
          ..write('timestamp: $timestamp, ')
          ..write('contextTags: $contextTags, ')
          ..write('location: $location, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('futureMessage: $futureMessage, ')
          ..write('isSharedToWorld: $isSharedToWorld, ')
          ..write('worldTopic: $worldTopic, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    circleId,
    authorId,
    content,
    mediaType,
    mediaUrls,
    timestamp,
    contextTags,
    location,
    isFavorite,
    futureMessage,
    isSharedToWorld,
    worldTopic,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    serverVersion,
    lastSyncAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Moment &&
          other.id == this.id &&
          other.circleId == this.circleId &&
          other.authorId == this.authorId &&
          other.content == this.content &&
          other.mediaType == this.mediaType &&
          other.mediaUrls == this.mediaUrls &&
          other.timestamp == this.timestamp &&
          other.contextTags == this.contextTags &&
          other.location == this.location &&
          other.isFavorite == this.isFavorite &&
          other.futureMessage == this.futureMessage &&
          other.isSharedToWorld == this.isSharedToWorld &&
          other.worldTopic == this.worldTopic &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.serverVersion == this.serverVersion &&
          other.lastSyncAt == this.lastSyncAt);
}

class MomentsCompanion extends UpdateCompanion<Moment> {
  final Value<String> id;
  final Value<String> circleId;
  final Value<String> authorId;
  final Value<String> content;
  final Value<String> mediaType;
  final Value<String> mediaUrls;
  final Value<DateTime> timestamp;
  final Value<String?> contextTags;
  final Value<String?> location;
  final Value<bool> isFavorite;
  final Value<String?> futureMessage;
  final Value<bool> isSharedToWorld;
  final Value<String?> worldTopic;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncStatus;
  final Value<int> serverVersion;
  final Value<DateTime?> lastSyncAt;
  final Value<int> rowid;
  const MomentsCompanion({
    this.id = const Value.absent(),
    this.circleId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.content = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.mediaUrls = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.contextTags = const Value.absent(),
    this.location = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.futureMessage = const Value.absent(),
    this.isSharedToWorld = const Value.absent(),
    this.worldTopic = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MomentsCompanion.insert({
    required String id,
    required String circleId,
    required String authorId,
    required String content,
    this.mediaType = const Value.absent(),
    this.mediaUrls = const Value.absent(),
    required DateTime timestamp,
    this.contextTags = const Value.absent(),
    this.location = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.futureMessage = const Value.absent(),
    this.isSharedToWorld = const Value.absent(),
    this.worldTopic = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       circleId = Value(circleId),
       authorId = Value(authorId),
       content = Value(content),
       timestamp = Value(timestamp),
       createdAt = Value(createdAt);
  static Insertable<Moment> custom({
    Expression<String>? id,
    Expression<String>? circleId,
    Expression<String>? authorId,
    Expression<String>? content,
    Expression<String>? mediaType,
    Expression<String>? mediaUrls,
    Expression<DateTime>? timestamp,
    Expression<String>? contextTags,
    Expression<String>? location,
    Expression<bool>? isFavorite,
    Expression<String>? futureMessage,
    Expression<bool>? isSharedToWorld,
    Expression<String>? worldTopic,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncStatus,
    Expression<int>? serverVersion,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (circleId != null) 'circle_id': circleId,
      if (authorId != null) 'author_id': authorId,
      if (content != null) 'content': content,
      if (mediaType != null) 'media_type': mediaType,
      if (mediaUrls != null) 'media_urls': mediaUrls,
      if (timestamp != null) 'timestamp': timestamp,
      if (contextTags != null) 'context_tags': contextTags,
      if (location != null) 'location': location,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (futureMessage != null) 'future_message': futureMessage,
      if (isSharedToWorld != null) 'is_shared_to_world': isSharedToWorld,
      if (worldTopic != null) 'world_topic': worldTopic,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverVersion != null) 'server_version': serverVersion,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MomentsCompanion copyWith({
    Value<String>? id,
    Value<String>? circleId,
    Value<String>? authorId,
    Value<String>? content,
    Value<String>? mediaType,
    Value<String>? mediaUrls,
    Value<DateTime>? timestamp,
    Value<String?>? contextTags,
    Value<String?>? location,
    Value<bool>? isFavorite,
    Value<String?>? futureMessage,
    Value<bool>? isSharedToWorld,
    Value<String?>? worldTopic,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncStatus,
    Value<int>? serverVersion,
    Value<DateTime?>? lastSyncAt,
    Value<int>? rowid,
  }) {
    return MomentsCompanion(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      mediaType: mediaType ?? this.mediaType,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      timestamp: timestamp ?? this.timestamp,
      contextTags: contextTags ?? this.contextTags,
      location: location ?? this.location,
      isFavorite: isFavorite ?? this.isFavorite,
      futureMessage: futureMessage ?? this.futureMessage,
      isSharedToWorld: isSharedToWorld ?? this.isSharedToWorld,
      worldTopic: worldTopic ?? this.worldTopic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      serverVersion: serverVersion ?? this.serverVersion,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (circleId.present) {
      map['circle_id'] = Variable<String>(circleId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (mediaUrls.present) {
      map['media_urls'] = Variable<String>(mediaUrls.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (contextTags.present) {
      map['context_tags'] = Variable<String>(contextTags.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (futureMessage.present) {
      map['future_message'] = Variable<String>(futureMessage.value);
    }
    if (isSharedToWorld.present) {
      map['is_shared_to_world'] = Variable<bool>(isSharedToWorld.value);
    }
    if (worldTopic.present) {
      map['world_topic'] = Variable<String>(worldTopic.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MomentsCompanion(')
          ..write('id: $id, ')
          ..write('circleId: $circleId, ')
          ..write('authorId: $authorId, ')
          ..write('content: $content, ')
          ..write('mediaType: $mediaType, ')
          ..write('mediaUrls: $mediaUrls, ')
          ..write('timestamp: $timestamp, ')
          ..write('contextTags: $contextTags, ')
          ..write('location: $location, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('futureMessage: $futureMessage, ')
          ..write('isSharedToWorld: $isSharedToWorld, ')
          ..write('worldTopic: $worldTopic, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MomentCacheInfoTable extends MomentCacheInfo
    with TableInfo<$MomentCacheInfoTable, MomentCacheInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MomentCacheInfoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _circleIdMeta = const VerificationMeta(
    'circleId',
  );
  @override
  late final GeneratedColumn<String> circleId = GeneratedColumn<String>(
    'circle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filterHashMeta = const VerificationMeta(
    'filterHash',
  );
  @override
  late final GeneratedColumn<String> filterHash = GeneratedColumn<String>(
    'filter_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _totalItemsMeta = const VerificationMeta(
    'totalItems',
  );
  @override
  late final GeneratedColumn<int> totalItems = GeneratedColumn<int>(
    'total_items',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hasMoreMeta = const VerificationMeta(
    'hasMore',
  );
  @override
  late final GeneratedColumn<bool> hasMore = GeneratedColumn<bool>(
    'has_more',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_more" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    circleId,
    filterHash,
    currentPage,
    totalItems,
    hasMore,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'moment_cache_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<MomentCacheInfoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('circle_id')) {
      context.handle(
        _circleIdMeta,
        circleId.isAcceptableOrUnknown(data['circle_id']!, _circleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circleIdMeta);
    }
    if (data.containsKey('filter_hash')) {
      context.handle(
        _filterHashMeta,
        filterHash.isAcceptableOrUnknown(data['filter_hash']!, _filterHashMeta),
      );
    } else if (isInserting) {
      context.missing(_filterHashMeta);
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('total_items')) {
      context.handle(
        _totalItemsMeta,
        totalItems.isAcceptableOrUnknown(data['total_items']!, _totalItemsMeta),
      );
    }
    if (data.containsKey('has_more')) {
      context.handle(
        _hasMoreMeta,
        hasMore.isAcceptableOrUnknown(data['has_more']!, _hasMoreMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {circleId, filterHash};
  @override
  MomentCacheInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MomentCacheInfoData(
      circleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}circle_id'],
          )!,
      filterHash:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}filter_hash'],
          )!,
      currentPage:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}current_page'],
          )!,
      totalItems:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}total_items'],
          )!,
      hasMore:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}has_more'],
          )!,
      cachedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}cached_at'],
          )!,
    );
  }

  @override
  $MomentCacheInfoTable createAlias(String alias) {
    return $MomentCacheInfoTable(attachedDatabase, alias);
  }
}

class MomentCacheInfoData extends DataClass
    implements Insertable<MomentCacheInfoData> {
  /// Circle ID
  final String circleId;

  /// Filter hash (to distinguish different filter combinations)
  final String filterHash;

  /// Current page loaded
  final int currentPage;

  /// Total items on server
  final int totalItems;

  /// Has more pages
  final bool hasMore;

  /// When this cache was last updated
  final DateTime cachedAt;
  const MomentCacheInfoData({
    required this.circleId,
    required this.filterHash,
    required this.currentPage,
    required this.totalItems,
    required this.hasMore,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['circle_id'] = Variable<String>(circleId);
    map['filter_hash'] = Variable<String>(filterHash);
    map['current_page'] = Variable<int>(currentPage);
    map['total_items'] = Variable<int>(totalItems);
    map['has_more'] = Variable<bool>(hasMore);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  MomentCacheInfoCompanion toCompanion(bool nullToAbsent) {
    return MomentCacheInfoCompanion(
      circleId: Value(circleId),
      filterHash: Value(filterHash),
      currentPage: Value(currentPage),
      totalItems: Value(totalItems),
      hasMore: Value(hasMore),
      cachedAt: Value(cachedAt),
    );
  }

  factory MomentCacheInfoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MomentCacheInfoData(
      circleId: serializer.fromJson<String>(json['circleId']),
      filterHash: serializer.fromJson<String>(json['filterHash']),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      totalItems: serializer.fromJson<int>(json['totalItems']),
      hasMore: serializer.fromJson<bool>(json['hasMore']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'circleId': serializer.toJson<String>(circleId),
      'filterHash': serializer.toJson<String>(filterHash),
      'currentPage': serializer.toJson<int>(currentPage),
      'totalItems': serializer.toJson<int>(totalItems),
      'hasMore': serializer.toJson<bool>(hasMore),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  MomentCacheInfoData copyWith({
    String? circleId,
    String? filterHash,
    int? currentPage,
    int? totalItems,
    bool? hasMore,
    DateTime? cachedAt,
  }) => MomentCacheInfoData(
    circleId: circleId ?? this.circleId,
    filterHash: filterHash ?? this.filterHash,
    currentPage: currentPage ?? this.currentPage,
    totalItems: totalItems ?? this.totalItems,
    hasMore: hasMore ?? this.hasMore,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  MomentCacheInfoData copyWithCompanion(MomentCacheInfoCompanion data) {
    return MomentCacheInfoData(
      circleId: data.circleId.present ? data.circleId.value : this.circleId,
      filterHash:
          data.filterHash.present ? data.filterHash.value : this.filterHash,
      currentPage:
          data.currentPage.present ? data.currentPage.value : this.currentPage,
      totalItems:
          data.totalItems.present ? data.totalItems.value : this.totalItems,
      hasMore: data.hasMore.present ? data.hasMore.value : this.hasMore,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MomentCacheInfoData(')
          ..write('circleId: $circleId, ')
          ..write('filterHash: $filterHash, ')
          ..write('currentPage: $currentPage, ')
          ..write('totalItems: $totalItems, ')
          ..write('hasMore: $hasMore, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    circleId,
    filterHash,
    currentPage,
    totalItems,
    hasMore,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MomentCacheInfoData &&
          other.circleId == this.circleId &&
          other.filterHash == this.filterHash &&
          other.currentPage == this.currentPage &&
          other.totalItems == this.totalItems &&
          other.hasMore == this.hasMore &&
          other.cachedAt == this.cachedAt);
}

class MomentCacheInfoCompanion extends UpdateCompanion<MomentCacheInfoData> {
  final Value<String> circleId;
  final Value<String> filterHash;
  final Value<int> currentPage;
  final Value<int> totalItems;
  final Value<bool> hasMore;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const MomentCacheInfoCompanion({
    this.circleId = const Value.absent(),
    this.filterHash = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.hasMore = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MomentCacheInfoCompanion.insert({
    required String circleId,
    required String filterHash,
    this.currentPage = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.hasMore = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : circleId = Value(circleId),
       filterHash = Value(filterHash),
       cachedAt = Value(cachedAt);
  static Insertable<MomentCacheInfoData> custom({
    Expression<String>? circleId,
    Expression<String>? filterHash,
    Expression<int>? currentPage,
    Expression<int>? totalItems,
    Expression<bool>? hasMore,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (circleId != null) 'circle_id': circleId,
      if (filterHash != null) 'filter_hash': filterHash,
      if (currentPage != null) 'current_page': currentPage,
      if (totalItems != null) 'total_items': totalItems,
      if (hasMore != null) 'has_more': hasMore,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MomentCacheInfoCompanion copyWith({
    Value<String>? circleId,
    Value<String>? filterHash,
    Value<int>? currentPage,
    Value<int>? totalItems,
    Value<bool>? hasMore,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return MomentCacheInfoCompanion(
      circleId: circleId ?? this.circleId,
      filterHash: filterHash ?? this.filterHash,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (circleId.present) {
      map['circle_id'] = Variable<String>(circleId.value);
    }
    if (filterHash.present) {
      map['filter_hash'] = Variable<String>(filterHash.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (totalItems.present) {
      map['total_items'] = Variable<int>(totalItems.value);
    }
    if (hasMore.present) {
      map['has_more'] = Variable<bool>(hasMore.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MomentCacheInfoCompanion(')
          ..write('circleId: $circleId, ')
          ..write('filterHash: $filterHash, ')
          ..write('currentPage: $currentPage, ')
          ..write('totalItems: $totalItems, ')
          ..write('hasMore: $hasMore, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LettersTable extends Letters with TableInfo<$LettersTable, Letter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LettersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _circleIdMeta = const VerificationMeta(
    'circleId',
  );
  @override
  late final GeneratedColumn<String> circleId = GeneratedColumn<String>(
    'circle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES circles (id)',
    ),
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previewMeta = const VerificationMeta(
    'preview',
  );
  @override
  late final GeneratedColumn<String> preview = GeneratedColumn<String>(
    'preview',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('free'),
  );
  static const VerificationMeta _recipientMeta = const VerificationMeta(
    'recipient',
  );
  @override
  late final GeneratedColumn<String> recipient = GeneratedColumn<String>(
    'recipient',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockDateMeta = const VerificationMeta(
    'unlockDate',
  );
  @override
  late final GeneratedColumn<DateTime> unlockDate = GeneratedColumn<DateTime>(
    'unlock_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sealedAtMeta = const VerificationMeta(
    'sealedAt',
  );
  @override
  late final GeneratedColumn<DateTime> sealedAt = GeneratedColumn<DateTime>(
    'sealed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<int> syncStatus = GeneratedColumn<int>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    circleId,
    authorId,
    title,
    preview,
    content,
    status,
    type,
    recipient,
    unlockDate,
    createdAt,
    sealedAt,
    updatedAt,
    deletedAt,
    syncStatus,
    serverVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'letters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Letter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('circle_id')) {
      context.handle(
        _circleIdMeta,
        circleId.isAcceptableOrUnknown(data['circle_id']!, _circleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circleIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('preview')) {
      context.handle(
        _previewMeta,
        preview.isAcceptableOrUnknown(data['preview']!, _previewMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('recipient')) {
      context.handle(
        _recipientMeta,
        recipient.isAcceptableOrUnknown(data['recipient']!, _recipientMeta),
      );
    } else if (isInserting) {
      context.missing(_recipientMeta);
    }
    if (data.containsKey('unlock_date')) {
      context.handle(
        _unlockDateMeta,
        unlockDate.isAcceptableOrUnknown(data['unlock_date']!, _unlockDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sealed_at')) {
      context.handle(
        _sealedAtMeta,
        sealedAt.isAcceptableOrUnknown(data['sealed_at']!, _sealedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Letter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Letter(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      circleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}circle_id'],
          )!,
      authorId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}author_id'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      preview:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}preview'],
          )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      recipient:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}recipient'],
          )!,
      unlockDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlock_date'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      sealedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sealed_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sync_status'],
          )!,
      serverVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}server_version'],
          )!,
    );
  }

  @override
  $LettersTable createAlias(String alias) {
    return $LettersTable(attachedDatabase, alias);
  }
}

class Letter extends DataClass implements Insertable<Letter> {
  /// Letter ID (from server or local UUID)
  final String id;

  /// Circle this letter belongs to
  final String circleId;

  /// Author user ID
  final String authorId;

  /// Letter title
  final String title;

  /// Preview text (first 100 chars)
  final String preview;

  /// Full content (null if sealed and not yet unlocked)
  final String? content;

  /// Status: draft, sealed, unlocked
  final String status;

  /// Type: annual, milestone, free
  final String type;

  /// Recipient name/description
  final String recipient;

  /// When the letter can be unlocked
  final DateTime? unlockDate;

  /// Creation time
  final DateTime createdAt;

  /// When the letter was sealed
  final DateTime? sealedAt;

  /// Last update time
  final DateTime? updatedAt;

  /// Soft delete time
  final DateTime? deletedAt;

  /// Sync status: 0=synced, 1=pendingCreate, 2=pendingUpdate, 3=pendingDelete, 4=failed
  final int syncStatus;

  /// Server version for conflict resolution
  final int serverVersion;
  const Letter({
    required this.id,
    required this.circleId,
    required this.authorId,
    required this.title,
    required this.preview,
    this.content,
    required this.status,
    required this.type,
    required this.recipient,
    this.unlockDate,
    required this.createdAt,
    this.sealedAt,
    this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.serverVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['circle_id'] = Variable<String>(circleId);
    map['author_id'] = Variable<String>(authorId);
    map['title'] = Variable<String>(title);
    map['preview'] = Variable<String>(preview);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['status'] = Variable<String>(status);
    map['type'] = Variable<String>(type);
    map['recipient'] = Variable<String>(recipient);
    if (!nullToAbsent || unlockDate != null) {
      map['unlock_date'] = Variable<DateTime>(unlockDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || sealedAt != null) {
      map['sealed_at'] = Variable<DateTime>(sealedAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<int>(syncStatus);
    map['server_version'] = Variable<int>(serverVersion);
    return map;
  }

  LettersCompanion toCompanion(bool nullToAbsent) {
    return LettersCompanion(
      id: Value(id),
      circleId: Value(circleId),
      authorId: Value(authorId),
      title: Value(title),
      preview: Value(preview),
      content:
          content == null && nullToAbsent
              ? const Value.absent()
              : Value(content),
      status: Value(status),
      type: Value(type),
      recipient: Value(recipient),
      unlockDate:
          unlockDate == null && nullToAbsent
              ? const Value.absent()
              : Value(unlockDate),
      createdAt: Value(createdAt),
      sealedAt:
          sealedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(sealedAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      deletedAt:
          deletedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(deletedAt),
      syncStatus: Value(syncStatus),
      serverVersion: Value(serverVersion),
    );
  }

  factory Letter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Letter(
      id: serializer.fromJson<String>(json['id']),
      circleId: serializer.fromJson<String>(json['circleId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      title: serializer.fromJson<String>(json['title']),
      preview: serializer.fromJson<String>(json['preview']),
      content: serializer.fromJson<String?>(json['content']),
      status: serializer.fromJson<String>(json['status']),
      type: serializer.fromJson<String>(json['type']),
      recipient: serializer.fromJson<String>(json['recipient']),
      unlockDate: serializer.fromJson<DateTime?>(json['unlockDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sealedAt: serializer.fromJson<DateTime?>(json['sealedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<int>(json['syncStatus']),
      serverVersion: serializer.fromJson<int>(json['serverVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'circleId': serializer.toJson<String>(circleId),
      'authorId': serializer.toJson<String>(authorId),
      'title': serializer.toJson<String>(title),
      'preview': serializer.toJson<String>(preview),
      'content': serializer.toJson<String?>(content),
      'status': serializer.toJson<String>(status),
      'type': serializer.toJson<String>(type),
      'recipient': serializer.toJson<String>(recipient),
      'unlockDate': serializer.toJson<DateTime?>(unlockDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sealedAt': serializer.toJson<DateTime?>(sealedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<int>(syncStatus),
      'serverVersion': serializer.toJson<int>(serverVersion),
    };
  }

  Letter copyWith({
    String? id,
    String? circleId,
    String? authorId,
    String? title,
    String? preview,
    Value<String?> content = const Value.absent(),
    String? status,
    String? type,
    String? recipient,
    Value<DateTime?> unlockDate = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> sealedAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncStatus,
    int? serverVersion,
  }) => Letter(
    id: id ?? this.id,
    circleId: circleId ?? this.circleId,
    authorId: authorId ?? this.authorId,
    title: title ?? this.title,
    preview: preview ?? this.preview,
    content: content.present ? content.value : this.content,
    status: status ?? this.status,
    type: type ?? this.type,
    recipient: recipient ?? this.recipient,
    unlockDate: unlockDate.present ? unlockDate.value : this.unlockDate,
    createdAt: createdAt ?? this.createdAt,
    sealedAt: sealedAt.present ? sealedAt.value : this.sealedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    serverVersion: serverVersion ?? this.serverVersion,
  );
  Letter copyWithCompanion(LettersCompanion data) {
    return Letter(
      id: data.id.present ? data.id.value : this.id,
      circleId: data.circleId.present ? data.circleId.value : this.circleId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      title: data.title.present ? data.title.value : this.title,
      preview: data.preview.present ? data.preview.value : this.preview,
      content: data.content.present ? data.content.value : this.content,
      status: data.status.present ? data.status.value : this.status,
      type: data.type.present ? data.type.value : this.type,
      recipient: data.recipient.present ? data.recipient.value : this.recipient,
      unlockDate:
          data.unlockDate.present ? data.unlockDate.value : this.unlockDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sealedAt: data.sealedAt.present ? data.sealedAt.value : this.sealedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      serverVersion:
          data.serverVersion.present
              ? data.serverVersion.value
              : this.serverVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Letter(')
          ..write('id: $id, ')
          ..write('circleId: $circleId, ')
          ..write('authorId: $authorId, ')
          ..write('title: $title, ')
          ..write('preview: $preview, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('type: $type, ')
          ..write('recipient: $recipient, ')
          ..write('unlockDate: $unlockDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('sealedAt: $sealedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverVersion: $serverVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    circleId,
    authorId,
    title,
    preview,
    content,
    status,
    type,
    recipient,
    unlockDate,
    createdAt,
    sealedAt,
    updatedAt,
    deletedAt,
    syncStatus,
    serverVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Letter &&
          other.id == this.id &&
          other.circleId == this.circleId &&
          other.authorId == this.authorId &&
          other.title == this.title &&
          other.preview == this.preview &&
          other.content == this.content &&
          other.status == this.status &&
          other.type == this.type &&
          other.recipient == this.recipient &&
          other.unlockDate == this.unlockDate &&
          other.createdAt == this.createdAt &&
          other.sealedAt == this.sealedAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.serverVersion == this.serverVersion);
}

class LettersCompanion extends UpdateCompanion<Letter> {
  final Value<String> id;
  final Value<String> circleId;
  final Value<String> authorId;
  final Value<String> title;
  final Value<String> preview;
  final Value<String?> content;
  final Value<String> status;
  final Value<String> type;
  final Value<String> recipient;
  final Value<DateTime?> unlockDate;
  final Value<DateTime> createdAt;
  final Value<DateTime?> sealedAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncStatus;
  final Value<int> serverVersion;
  final Value<int> rowid;
  const LettersCompanion({
    this.id = const Value.absent(),
    this.circleId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.title = const Value.absent(),
    this.preview = const Value.absent(),
    this.content = const Value.absent(),
    this.status = const Value.absent(),
    this.type = const Value.absent(),
    this.recipient = const Value.absent(),
    this.unlockDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sealedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LettersCompanion.insert({
    required String id,
    required String circleId,
    required String authorId,
    required String title,
    this.preview = const Value.absent(),
    this.content = const Value.absent(),
    this.status = const Value.absent(),
    this.type = const Value.absent(),
    required String recipient,
    this.unlockDate = const Value.absent(),
    required DateTime createdAt,
    this.sealedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       circleId = Value(circleId),
       authorId = Value(authorId),
       title = Value(title),
       recipient = Value(recipient),
       createdAt = Value(createdAt);
  static Insertable<Letter> custom({
    Expression<String>? id,
    Expression<String>? circleId,
    Expression<String>? authorId,
    Expression<String>? title,
    Expression<String>? preview,
    Expression<String>? content,
    Expression<String>? status,
    Expression<String>? type,
    Expression<String>? recipient,
    Expression<DateTime>? unlockDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? sealedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncStatus,
    Expression<int>? serverVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (circleId != null) 'circle_id': circleId,
      if (authorId != null) 'author_id': authorId,
      if (title != null) 'title': title,
      if (preview != null) 'preview': preview,
      if (content != null) 'content': content,
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      if (recipient != null) 'recipient': recipient,
      if (unlockDate != null) 'unlock_date': unlockDate,
      if (createdAt != null) 'created_at': createdAt,
      if (sealedAt != null) 'sealed_at': sealedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverVersion != null) 'server_version': serverVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LettersCompanion copyWith({
    Value<String>? id,
    Value<String>? circleId,
    Value<String>? authorId,
    Value<String>? title,
    Value<String>? preview,
    Value<String?>? content,
    Value<String>? status,
    Value<String>? type,
    Value<String>? recipient,
    Value<DateTime?>? unlockDate,
    Value<DateTime>? createdAt,
    Value<DateTime?>? sealedAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncStatus,
    Value<int>? serverVersion,
    Value<int>? rowid,
  }) {
    return LettersCompanion(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      content: content ?? this.content,
      status: status ?? this.status,
      type: type ?? this.type,
      recipient: recipient ?? this.recipient,
      unlockDate: unlockDate ?? this.unlockDate,
      createdAt: createdAt ?? this.createdAt,
      sealedAt: sealedAt ?? this.sealedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      serverVersion: serverVersion ?? this.serverVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (circleId.present) {
      map['circle_id'] = Variable<String>(circleId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (preview.present) {
      map['preview'] = Variable<String>(preview.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (recipient.present) {
      map['recipient'] = Variable<String>(recipient.value);
    }
    if (unlockDate.present) {
      map['unlock_date'] = Variable<DateTime>(unlockDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sealedAt.present) {
      map['sealed_at'] = Variable<DateTime>(sealedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(syncStatus.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LettersCompanion(')
          ..write('id: $id, ')
          ..write('circleId: $circleId, ')
          ..write('authorId: $authorId, ')
          ..write('title: $title, ')
          ..write('preview: $preview, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('type: $type, ')
          ..write('recipient: $recipient, ')
          ..write('unlockDate: $unlockDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('sealedAt: $sealedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncLogTable extends SyncLog with TableInfo<$SyncLogTable, SyncLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _circleIdMeta = const VerificationMeta(
    'circleId',
  );
  @override
  late final GeneratedColumn<String> circleId = GeneratedColumn<String>(
    'circle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    circleId,
    entityType,
    entityId,
    action,
    data,
    timestamp,
    attempts,
    lastError,
    isSynced,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('circle_id')) {
      context.handle(
        _circleIdMeta,
        circleId.isAcceptableOrUnknown(data['circle_id']!, _circleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circleIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLogData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      circleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}circle_id'],
          )!,
      entityType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_type'],
          )!,
      entityId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_id'],
          )!,
      action:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}action'],
          )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
      attempts:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}attempts'],
          )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      isSynced:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_synced'],
          )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $SyncLogTable createAlias(String alias) {
    return $SyncLogTable(attachedDatabase, alias);
  }
}

class SyncLogData extends DataClass implements Insertable<SyncLogData> {
  /// Auto-increment ID
  final int id;

  /// Circle ID (for scoping)
  final String circleId;

  /// Entity type: moment, letter, comment, etc.
  final String entityType;

  /// Entity ID
  final String entityId;

  /// Action: create, update, delete
  final String action;

  /// Full entity data as JSON (for create/update)
  final String? data;

  /// When this change happened locally
  final DateTime timestamp;

  /// Number of sync attempts
  final int attempts;

  /// Last error message if failed
  final String? lastError;

  /// Is this change synced
  final bool isSynced;

  /// When it was synced
  final DateTime? syncedAt;
  const SyncLogData({
    required this.id,
    required this.circleId,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.data,
    required this.timestamp,
    required this.attempts,
    this.lastError,
    required this.isSynced,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['circle_id'] = Variable<String>(circleId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  SyncLogCompanion toCompanion(bool nullToAbsent) {
    return SyncLogCompanion(
      id: Value(id),
      circleId: Value(circleId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      timestamp: Value(timestamp),
      attempts: Value(attempts),
      lastError:
          lastError == null && nullToAbsent
              ? const Value.absent()
              : Value(lastError),
      isSynced: Value(isSynced),
      syncedAt:
          syncedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(syncedAt),
    );
  }

  factory SyncLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLogData(
      id: serializer.fromJson<int>(json['id']),
      circleId: serializer.fromJson<String>(json['circleId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      data: serializer.fromJson<String?>(json['data']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'circleId': serializer.toJson<String>(circleId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'data': serializer.toJson<String?>(data),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'isSynced': serializer.toJson<bool>(isSynced),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  SyncLogData copyWith({
    int? id,
    String? circleId,
    String? entityType,
    String? entityId,
    String? action,
    Value<String?> data = const Value.absent(),
    DateTime? timestamp,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
    bool? isSynced,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => SyncLogData(
    id: id ?? this.id,
    circleId: circleId ?? this.circleId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    data: data.present ? data.value : this.data,
    timestamp: timestamp ?? this.timestamp,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
    isSynced: isSynced ?? this.isSynced,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SyncLogData copyWithCompanion(SyncLogCompanion data) {
    return SyncLogData(
      id: data.id.present ? data.id.value : this.id,
      circleId: data.circleId.present ? data.circleId.value : this.circleId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      data: data.data.present ? data.data.value : this.data,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogData(')
          ..write('id: $id, ')
          ..write('circleId: $circleId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('data: $data, ')
          ..write('timestamp: $timestamp, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    circleId,
    entityType,
    entityId,
    action,
    data,
    timestamp,
    attempts,
    lastError,
    isSynced,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLogData &&
          other.id == this.id &&
          other.circleId == this.circleId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.data == this.data &&
          other.timestamp == this.timestamp &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.isSynced == this.isSynced &&
          other.syncedAt == this.syncedAt);
}

class SyncLogCompanion extends UpdateCompanion<SyncLogData> {
  final Value<int> id;
  final Value<String> circleId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String?> data;
  final Value<DateTime> timestamp;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<bool> isSynced;
  final Value<DateTime?> syncedAt;
  const SyncLogCompanion({
    this.id = const Value.absent(),
    this.circleId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.data = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  SyncLogCompanion.insert({
    this.id = const Value.absent(),
    required String circleId,
    required String entityType,
    required String entityId,
    required String action,
    this.data = const Value.absent(),
    required DateTime timestamp,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.syncedAt = const Value.absent(),
  }) : circleId = Value(circleId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       timestamp = Value(timestamp);
  static Insertable<SyncLogData> custom({
    Expression<int>? id,
    Expression<String>? circleId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? data,
    Expression<DateTime>? timestamp,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<bool>? isSynced,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (circleId != null) 'circle_id': circleId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (data != null) 'data': data,
      if (timestamp != null) 'timestamp': timestamp,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (isSynced != null) 'is_synced': isSynced,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  SyncLogCompanion copyWith({
    Value<int>? id,
    Value<String>? circleId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? action,
    Value<String?>? data,
    Value<DateTime>? timestamp,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<bool>? isSynced,
    Value<DateTime?>? syncedAt,
  }) {
    return SyncLogCompanion(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (circleId.present) {
      map['circle_id'] = Variable<String>(circleId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogCompanion(')
          ..write('id: $id, ')
          ..write('circleId: $circleId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('data: $data, ')
          ..write('timestamp: $timestamp, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('isSynced: $isSynced, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncStatusTable extends SyncStatus
    with TableInfo<$SyncStatusTable, SyncStatusData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _circleIdMeta = const VerificationMeta(
    'circleId',
  );
  @override
  late final GeneratedColumn<String> circleId = GeneratedColumn<String>(
    'circle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastFullSyncMeta = const VerificationMeta(
    'lastFullSync',
  );
  @override
  late final GeneratedColumn<DateTime> lastFullSync = GeneratedColumn<DateTime>(
    'last_full_sync',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastIncrementalSyncMeta =
      const VerificationMeta('lastIncrementalSync');
  @override
  late final GeneratedColumn<DateTime> lastIncrementalSync =
      GeneratedColumn<DateTime>(
        'last_incremental_sync',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pendingChangesMeta = const VerificationMeta(
    'pendingChanges',
  );
  @override
  late final GeneratedColumn<int> pendingChanges = GeneratedColumn<int>(
    'pending_changes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isSyncingMeta = const VerificationMeta(
    'isSyncing',
  );
  @override
  late final GeneratedColumn<bool> isSyncing = GeneratedColumn<bool>(
    'is_syncing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_syncing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    circleId,
    lastFullSync,
    lastIncrementalSync,
    pendingChanges,
    isSyncing,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_status';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStatusData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('circle_id')) {
      context.handle(
        _circleIdMeta,
        circleId.isAcceptableOrUnknown(data['circle_id']!, _circleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_circleIdMeta);
    }
    if (data.containsKey('last_full_sync')) {
      context.handle(
        _lastFullSyncMeta,
        lastFullSync.isAcceptableOrUnknown(
          data['last_full_sync']!,
          _lastFullSyncMeta,
        ),
      );
    }
    if (data.containsKey('last_incremental_sync')) {
      context.handle(
        _lastIncrementalSyncMeta,
        lastIncrementalSync.isAcceptableOrUnknown(
          data['last_incremental_sync']!,
          _lastIncrementalSyncMeta,
        ),
      );
    }
    if (data.containsKey('pending_changes')) {
      context.handle(
        _pendingChangesMeta,
        pendingChanges.isAcceptableOrUnknown(
          data['pending_changes']!,
          _pendingChangesMeta,
        ),
      );
    }
    if (data.containsKey('is_syncing')) {
      context.handle(
        _isSyncingMeta,
        isSyncing.isAcceptableOrUnknown(data['is_syncing']!, _isSyncingMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {circleId};
  @override
  SyncStatusData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStatusData(
      circleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}circle_id'],
          )!,
      lastFullSync: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_full_sync'],
      ),
      lastIncrementalSync: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_incremental_sync'],
      ),
      pendingChanges:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}pending_changes'],
          )!,
      isSyncing:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_syncing'],
          )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncStatusTable createAlias(String alias) {
    return $SyncStatusTable(attachedDatabase, alias);
  }
}

class SyncStatusData extends DataClass implements Insertable<SyncStatusData> {
  /// Circle ID
  final String circleId;

  /// Last successful full sync timestamp
  final DateTime? lastFullSync;

  /// Last successful incremental sync timestamp
  final DateTime? lastIncrementalSync;

  /// Number of pending changes
  final int pendingChanges;

  /// Is currently syncing
  final bool isSyncing;

  /// Last sync error
  final String? lastError;
  const SyncStatusData({
    required this.circleId,
    this.lastFullSync,
    this.lastIncrementalSync,
    required this.pendingChanges,
    required this.isSyncing,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['circle_id'] = Variable<String>(circleId);
    if (!nullToAbsent || lastFullSync != null) {
      map['last_full_sync'] = Variable<DateTime>(lastFullSync);
    }
    if (!nullToAbsent || lastIncrementalSync != null) {
      map['last_incremental_sync'] = Variable<DateTime>(lastIncrementalSync);
    }
    map['pending_changes'] = Variable<int>(pendingChanges);
    map['is_syncing'] = Variable<bool>(isSyncing);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncStatusCompanion toCompanion(bool nullToAbsent) {
    return SyncStatusCompanion(
      circleId: Value(circleId),
      lastFullSync:
          lastFullSync == null && nullToAbsent
              ? const Value.absent()
              : Value(lastFullSync),
      lastIncrementalSync:
          lastIncrementalSync == null && nullToAbsent
              ? const Value.absent()
              : Value(lastIncrementalSync),
      pendingChanges: Value(pendingChanges),
      isSyncing: Value(isSyncing),
      lastError:
          lastError == null && nullToAbsent
              ? const Value.absent()
              : Value(lastError),
    );
  }

  factory SyncStatusData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStatusData(
      circleId: serializer.fromJson<String>(json['circleId']),
      lastFullSync: serializer.fromJson<DateTime?>(json['lastFullSync']),
      lastIncrementalSync: serializer.fromJson<DateTime?>(
        json['lastIncrementalSync'],
      ),
      pendingChanges: serializer.fromJson<int>(json['pendingChanges']),
      isSyncing: serializer.fromJson<bool>(json['isSyncing']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'circleId': serializer.toJson<String>(circleId),
      'lastFullSync': serializer.toJson<DateTime?>(lastFullSync),
      'lastIncrementalSync': serializer.toJson<DateTime?>(lastIncrementalSync),
      'pendingChanges': serializer.toJson<int>(pendingChanges),
      'isSyncing': serializer.toJson<bool>(isSyncing),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncStatusData copyWith({
    String? circleId,
    Value<DateTime?> lastFullSync = const Value.absent(),
    Value<DateTime?> lastIncrementalSync = const Value.absent(),
    int? pendingChanges,
    bool? isSyncing,
    Value<String?> lastError = const Value.absent(),
  }) => SyncStatusData(
    circleId: circleId ?? this.circleId,
    lastFullSync: lastFullSync.present ? lastFullSync.value : this.lastFullSync,
    lastIncrementalSync:
        lastIncrementalSync.present
            ? lastIncrementalSync.value
            : this.lastIncrementalSync,
    pendingChanges: pendingChanges ?? this.pendingChanges,
    isSyncing: isSyncing ?? this.isSyncing,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncStatusData copyWithCompanion(SyncStatusCompanion data) {
    return SyncStatusData(
      circleId: data.circleId.present ? data.circleId.value : this.circleId,
      lastFullSync:
          data.lastFullSync.present
              ? data.lastFullSync.value
              : this.lastFullSync,
      lastIncrementalSync:
          data.lastIncrementalSync.present
              ? data.lastIncrementalSync.value
              : this.lastIncrementalSync,
      pendingChanges:
          data.pendingChanges.present
              ? data.pendingChanges.value
              : this.pendingChanges,
      isSyncing: data.isSyncing.present ? data.isSyncing.value : this.isSyncing,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatusData(')
          ..write('circleId: $circleId, ')
          ..write('lastFullSync: $lastFullSync, ')
          ..write('lastIncrementalSync: $lastIncrementalSync, ')
          ..write('pendingChanges: $pendingChanges, ')
          ..write('isSyncing: $isSyncing, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    circleId,
    lastFullSync,
    lastIncrementalSync,
    pendingChanges,
    isSyncing,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStatusData &&
          other.circleId == this.circleId &&
          other.lastFullSync == this.lastFullSync &&
          other.lastIncrementalSync == this.lastIncrementalSync &&
          other.pendingChanges == this.pendingChanges &&
          other.isSyncing == this.isSyncing &&
          other.lastError == this.lastError);
}

class SyncStatusCompanion extends UpdateCompanion<SyncStatusData> {
  final Value<String> circleId;
  final Value<DateTime?> lastFullSync;
  final Value<DateTime?> lastIncrementalSync;
  final Value<int> pendingChanges;
  final Value<bool> isSyncing;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncStatusCompanion({
    this.circleId = const Value.absent(),
    this.lastFullSync = const Value.absent(),
    this.lastIncrementalSync = const Value.absent(),
    this.pendingChanges = const Value.absent(),
    this.isSyncing = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatusCompanion.insert({
    required String circleId,
    this.lastFullSync = const Value.absent(),
    this.lastIncrementalSync = const Value.absent(),
    this.pendingChanges = const Value.absent(),
    this.isSyncing = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : circleId = Value(circleId);
  static Insertable<SyncStatusData> custom({
    Expression<String>? circleId,
    Expression<DateTime>? lastFullSync,
    Expression<DateTime>? lastIncrementalSync,
    Expression<int>? pendingChanges,
    Expression<bool>? isSyncing,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (circleId != null) 'circle_id': circleId,
      if (lastFullSync != null) 'last_full_sync': lastFullSync,
      if (lastIncrementalSync != null)
        'last_incremental_sync': lastIncrementalSync,
      if (pendingChanges != null) 'pending_changes': pendingChanges,
      if (isSyncing != null) 'is_syncing': isSyncing,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatusCompanion copyWith({
    Value<String>? circleId,
    Value<DateTime?>? lastFullSync,
    Value<DateTime?>? lastIncrementalSync,
    Value<int>? pendingChanges,
    Value<bool>? isSyncing,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncStatusCompanion(
      circleId: circleId ?? this.circleId,
      lastFullSync: lastFullSync ?? this.lastFullSync,
      lastIncrementalSync: lastIncrementalSync ?? this.lastIncrementalSync,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      isSyncing: isSyncing ?? this.isSyncing,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (circleId.present) {
      map['circle_id'] = Variable<String>(circleId.value);
    }
    if (lastFullSync.present) {
      map['last_full_sync'] = Variable<DateTime>(lastFullSync.value);
    }
    if (lastIncrementalSync.present) {
      map['last_incremental_sync'] = Variable<DateTime>(
        lastIncrementalSync.value,
      );
    }
    if (pendingChanges.present) {
      map['pending_changes'] = Variable<int>(pendingChanges.value);
    }
    if (isSyncing.present) {
      map['is_syncing'] = Variable<bool>(isSyncing.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatusCompanion(')
          ..write('circleId: $circleId, ')
          ..write('lastFullSync: $lastFullSync, ')
          ..write('lastIncrementalSync: $lastIncrementalSync, ')
          ..write('pendingChanges: $pendingChanges, ')
          ..write('isSyncing: $isSyncing, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}value'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  /// Setting key
  final String key;

  /// Setting value (JSON or string)
  final String value;

  /// When this setting was last updated
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $CirclesTable circles = $CirclesTable(this);
  late final $CircleMembersTable circleMembers = $CircleMembersTable(this);
  late final $MomentsTable moments = $MomentsTable(this);
  late final $MomentCacheInfoTable momentCacheInfo = $MomentCacheInfoTable(
    this,
  );
  late final $LettersTable letters = $LettersTable(this);
  late final $SyncLogTable syncLog = $SyncLogTable(this);
  late final $SyncStatusTable syncStatus = $SyncStatusTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final MomentsDao momentsDao = MomentsDao(this as AppDatabase);
  late final LettersDao lettersDao = LettersDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    circles,
    circleMembers,
    moments,
    momentCacheInfo,
    letters,
    syncLog,
    syncStatus,
    appSettings,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String email,
      required String name,
      Value<String?> avatar,
      Value<String?> roleLabel,
      Value<DateTime?> joinedAt,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> syncStatus,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> name,
      Value<String?> avatar,
      Value<String?> roleLabel,
      Value<DateTime?> joinedAt,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> syncStatus,
      Value<int> rowid,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CircleMembersTable, List<CircleMember>>
  _circleMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.circleMembers,
    aliasName: $_aliasNameGenerator(db.users.id, db.circleMembers.userId),
  );

  $$CircleMembersTableProcessedTableManager get circleMembersRefs {
    final manager = $$CircleMembersTableTableManager(
      $_db,
      $_db.circleMembers,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_circleMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MomentsTable, List<Moment>> _momentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.moments,
    aliasName: $_aliasNameGenerator(db.users.id, db.moments.authorId),
  );

  $$MomentsTableProcessedTableManager get momentsRefs {
    final manager = $$MomentsTableTableManager(
      $_db,
      $_db.moments,
    ).filter((f) => f.authorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_momentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LettersTable, List<Letter>> _lettersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.letters,
    aliasName: $_aliasNameGenerator(db.users.id, db.letters.authorId),
  );

  $$LettersTableProcessedTableManager get lettersRefs {
    final manager = $$LettersTableTableManager(
      $_db,
      $_db.letters,
    ).filter((f) => f.authorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lettersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleLabel => $composableBuilder(
    column: $table.roleLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> circleMembersRefs(
    Expression<bool> Function($$CircleMembersTableFilterComposer f) f,
  ) {
    final $$CircleMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.circleMembers,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CircleMembersTableFilterComposer(
            $db: $db,
            $table: $db.circleMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> momentsRefs(
    Expression<bool> Function($$MomentsTableFilterComposer f) f,
  ) {
    final $$MomentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moments,
      getReferencedColumn: (t) => t.authorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MomentsTableFilterComposer(
            $db: $db,
            $table: $db.moments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lettersRefs(
    Expression<bool> Function($$LettersTableFilterComposer f) f,
  ) {
    final $$LettersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.letters,
      getReferencedColumn: (t) => t.authorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LettersTableFilterComposer(
            $db: $db,
            $table: $db.letters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleLabel => $composableBuilder(
    column: $table.roleLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get roleLabel =>
      $composableBuilder(column: $table.roleLabel, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  Expression<T> circleMembersRefs<T extends Object>(
    Expression<T> Function($$CircleMembersTableAnnotationComposer a) f,
  ) {
    final $$CircleMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.circleMembers,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CircleMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.circleMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> momentsRefs<T extends Object>(
    Expression<T> Function($$MomentsTableAnnotationComposer a) f,
  ) {
    final $$MomentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moments,
      getReferencedColumn: (t) => t.authorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MomentsTableAnnotationComposer(
            $db: $db,
            $table: $db.moments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lettersRefs<T extends Object>(
    Expression<T> Function($$LettersTableAnnotationComposer a) f,
  ) {
    final $$LettersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.letters,
      getReferencedColumn: (t) => t.authorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LettersTableAnnotationComposer(
            $db: $db,
            $table: $db.letters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({
            bool circleMembersRefs,
            bool momentsRefs,
            bool lettersRefs,
          })
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<String?> roleLabel = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                name: name,
                avatar: avatar,
                roleLabel: roleLabel,
                joinedAt: joinedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String name,
                Value<String?> avatar = const Value.absent(),
                Value<String?> roleLabel = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                name: name,
                avatar: avatar,
                roleLabel: roleLabel,
                joinedAt: joinedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$UsersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            circleMembersRefs = false,
            momentsRefs = false,
            lettersRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (circleMembersRefs) db.circleMembers,
                if (momentsRefs) db.moments,
                if (lettersRefs) db.letters,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (circleMembersRefs)
                    await $_getPrefetchedData<User, $UsersTable, CircleMember>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences
                          ._circleMembersRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).circleMembersRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) =>
                              referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                  if (momentsRefs)
                    await $_getPrefetchedData<User, $UsersTable, Moment>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences._momentsRefsTable(
                        db,
                      ),
                      managerFromTypedResult:
                          (p0) =>
                              $$UsersTableReferences(db, table, p0).momentsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.authorId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (lettersRefs)
                    await $_getPrefetchedData<User, $UsersTable, Letter>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences._lettersRefsTable(
                        db,
                      ),
                      managerFromTypedResult:
                          (p0) =>
                              $$UsersTableReferences(db, table, p0).lettersRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.authorId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({
        bool circleMembersRefs,
        bool momentsRefs,
        bool lettersRefs,
      })
    >;
typedef $$CirclesTableCreateCompanionBuilder =
    CirclesCompanion Function({
      required String id,
      required String name,
      Value<DateTime?> startDate,
      Value<String?> inviteCode,
      Value<DateTime?> inviteExpiresAt,
      required String createdBy,
      Value<String?> role,
      Value<String?> roleLabel,
      Value<DateTime?> joinedAt,
      Value<int> memberCount,
      Value<int> momentCount,
      Value<int> letterCount,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> syncStatus,
      Value<int> rowid,
    });
typedef $$CirclesTableUpdateCompanionBuilder =
    CirclesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime?> startDate,
      Value<String?> inviteCode,
      Value<DateTime?> inviteExpiresAt,
      Value<String> createdBy,
      Value<String?> role,
      Value<String?> roleLabel,
      Value<DateTime?> joinedAt,
      Value<int> memberCount,
      Value<int> momentCount,
      Value<int> letterCount,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> syncStatus,
      Value<int> rowid,
    });

final class $$CirclesTableReferences
    extends BaseReferences<_$AppDatabase, $CirclesTable, Circle> {
  $$CirclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CircleMembersTable, List<CircleMember>>
  _circleMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.circleMembers,
    aliasName: $_aliasNameGenerator(db.circles.id, db.circleMembers.circleId),
  );

  $$CircleMembersTableProcessedTableManager get circleMembersRefs {
    final manager = $$CircleMembersTableTableManager(
      $_db,
      $_db.circleMembers,
    ).filter((f) => f.circleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_circleMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MomentsTable, List<Moment>> _momentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.moments,
    aliasName: $_aliasNameGenerator(db.circles.id, db.moments.circleId),
  );

  $$MomentsTableProcessedTableManager get momentsRefs {
    final manager = $$MomentsTableTableManager(
      $_db,
      $_db.moments,
    ).filter((f) => f.circleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_momentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LettersTable, List<Letter>> _lettersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.letters,
    aliasName: $_aliasNameGenerator(db.circles.id, db.letters.circleId),
  );

  $$LettersTableProcessedTableManager get lettersRefs {
    final manager = $$LettersTableTableManager(
      $_db,
      $_db.letters,
    ).filter((f) => f.circleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lettersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CirclesTableFilterComposer
    extends Composer<_$AppDatabase, $CirclesTable> {
  $$CirclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inviteExpiresAt => $composableBuilder(
    column: $table.inviteExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleLabel => $composableBuilder(
    column: $table.roleLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get momentCount => $composableBuilder(
    column: $table.momentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get letterCount => $composableBuilder(
    column: $table.letterCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> circleMembersRefs(
    Expression<bool> Function($$CircleMembersTableFilterComposer f) f,
  ) {
    final $$CircleMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.circleMembers,
      getReferencedColumn: (t) => t.circleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CircleMembersTableFilterComposer(
            $db: $db,
            $table: $db.circleMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> momentsRefs(
    Expression<bool> Function($$MomentsTableFilterComposer f) f,
  ) {
    final $$MomentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moments,
      getReferencedColumn: (t) => t.circleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MomentsTableFilterComposer(
            $db: $db,
            $table: $db.moments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lettersRefs(
    Expression<bool> Function($$LettersTableFilterComposer f) f,
  ) {
    final $$LettersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.letters,
      getReferencedColumn: (t) => t.circleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LettersTableFilterComposer(
            $db: $db,
            $table: $db.letters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CirclesTableOrderingComposer
    extends Composer<_$AppDatabase, $CirclesTable> {
  $$CirclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inviteExpiresAt => $composableBuilder(
    column: $table.inviteExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleLabel => $composableBuilder(
    column: $table.roleLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get momentCount => $composableBuilder(
    column: $table.momentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get letterCount => $composableBuilder(
    column: $table.letterCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CirclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CirclesTable> {
  $$CirclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get inviteCode => $composableBuilder(
    column: $table.inviteCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get inviteExpiresAt => $composableBuilder(
    column: $table.inviteExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get roleLabel =>
      $composableBuilder(column: $table.roleLabel, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get momentCount => $composableBuilder(
    column: $table.momentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get letterCount => $composableBuilder(
    column: $table.letterCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  Expression<T> circleMembersRefs<T extends Object>(
    Expression<T> Function($$CircleMembersTableAnnotationComposer a) f,
  ) {
    final $$CircleMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.circleMembers,
      getReferencedColumn: (t) => t.circleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CircleMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.circleMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> momentsRefs<T extends Object>(
    Expression<T> Function($$MomentsTableAnnotationComposer a) f,
  ) {
    final $$MomentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.moments,
      getReferencedColumn: (t) => t.circleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MomentsTableAnnotationComposer(
            $db: $db,
            $table: $db.moments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lettersRefs<T extends Object>(
    Expression<T> Function($$LettersTableAnnotationComposer a) f,
  ) {
    final $$LettersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.letters,
      getReferencedColumn: (t) => t.circleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LettersTableAnnotationComposer(
            $db: $db,
            $table: $db.letters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CirclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CirclesTable,
          Circle,
          $$CirclesTableFilterComposer,
          $$CirclesTableOrderingComposer,
          $$CirclesTableAnnotationComposer,
          $$CirclesTableCreateCompanionBuilder,
          $$CirclesTableUpdateCompanionBuilder,
          (Circle, $$CirclesTableReferences),
          Circle,
          PrefetchHooks Function({
            bool circleMembersRefs,
            bool momentsRefs,
            bool lettersRefs,
          })
        > {
  $$CirclesTableTableManager(_$AppDatabase db, $CirclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CirclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CirclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CirclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<String?> inviteCode = const Value.absent(),
                Value<DateTime?> inviteExpiresAt = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> roleLabel = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
                Value<int> memberCount = const Value.absent(),
                Value<int> momentCount = const Value.absent(),
                Value<int> letterCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CirclesCompanion(
                id: id,
                name: name,
                startDate: startDate,
                inviteCode: inviteCode,
                inviteExpiresAt: inviteExpiresAt,
                createdBy: createdBy,
                role: role,
                roleLabel: roleLabel,
                joinedAt: joinedAt,
                memberCount: memberCount,
                momentCount: momentCount,
                letterCount: letterCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<DateTime?> startDate = const Value.absent(),
                Value<String?> inviteCode = const Value.absent(),
                Value<DateTime?> inviteExpiresAt = const Value.absent(),
                required String createdBy,
                Value<String?> role = const Value.absent(),
                Value<String?> roleLabel = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
                Value<int> memberCount = const Value.absent(),
                Value<int> momentCount = const Value.absent(),
                Value<int> letterCount = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CirclesCompanion.insert(
                id: id,
                name: name,
                startDate: startDate,
                inviteCode: inviteCode,
                inviteExpiresAt: inviteExpiresAt,
                createdBy: createdBy,
                role: role,
                roleLabel: roleLabel,
                joinedAt: joinedAt,
                memberCount: memberCount,
                momentCount: momentCount,
                letterCount: letterCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CirclesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            circleMembersRefs = false,
            momentsRefs = false,
            lettersRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (circleMembersRefs) db.circleMembers,
                if (momentsRefs) db.moments,
                if (lettersRefs) db.letters,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (circleMembersRefs)
                    await $_getPrefetchedData<
                      Circle,
                      $CirclesTable,
                      CircleMember
                    >(
                      currentTable: table,
                      referencedTable: $$CirclesTableReferences
                          ._circleMembersRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CirclesTableReferences(
                                db,
                                table,
                                p0,
                              ).circleMembersRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.circleId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (momentsRefs)
                    await $_getPrefetchedData<Circle, $CirclesTable, Moment>(
                      currentTable: table,
                      referencedTable: $$CirclesTableReferences
                          ._momentsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CirclesTableReferences(
                                db,
                                table,
                                p0,
                              ).momentsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.circleId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (lettersRefs)
                    await $_getPrefetchedData<Circle, $CirclesTable, Letter>(
                      currentTable: table,
                      referencedTable: $$CirclesTableReferences
                          ._lettersRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$CirclesTableReferences(
                                db,
                                table,
                                p0,
                              ).lettersRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.circleId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CirclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CirclesTable,
      Circle,
      $$CirclesTableFilterComposer,
      $$CirclesTableOrderingComposer,
      $$CirclesTableAnnotationComposer,
      $$CirclesTableCreateCompanionBuilder,
      $$CirclesTableUpdateCompanionBuilder,
      (Circle, $$CirclesTableReferences),
      Circle,
      PrefetchHooks Function({
        bool circleMembersRefs,
        bool momentsRefs,
        bool lettersRefs,
      })
    >;
typedef $$CircleMembersTableCreateCompanionBuilder =
    CircleMembersCompanion Function({
      required String circleId,
      required String userId,
      required String role,
      Value<String?> roleLabel,
      required DateTime joinedAt,
      Value<int> rowid,
    });
typedef $$CircleMembersTableUpdateCompanionBuilder =
    CircleMembersCompanion Function({
      Value<String> circleId,
      Value<String> userId,
      Value<String> role,
      Value<String?> roleLabel,
      Value<DateTime> joinedAt,
      Value<int> rowid,
    });

final class $$CircleMembersTableReferences
    extends BaseReferences<_$AppDatabase, $CircleMembersTable, CircleMember> {
  $$CircleMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CirclesTable _circleIdTable(_$AppDatabase db) =>
      db.circles.createAlias(
        $_aliasNameGenerator(db.circleMembers.circleId, db.circles.id),
      );

  $$CirclesTableProcessedTableManager get circleId {
    final $_column = $_itemColumn<String>('circle_id')!;

    final manager = $$CirclesTableTableManager(
      $_db,
      $_db.circles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_circleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _userIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.circleMembers.userId, db.users.id),
  );

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CircleMembersTableFilterComposer
    extends Composer<_$AppDatabase, $CircleMembersTable> {
  $$CircleMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roleLabel => $composableBuilder(
    column: $table.roleLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CirclesTableFilterComposer get circleId {
    final $$CirclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableFilterComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CircleMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $CircleMembersTable> {
  $$CircleMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roleLabel => $composableBuilder(
    column: $table.roleLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CirclesTableOrderingComposer get circleId {
    final $$CirclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableOrderingComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CircleMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CircleMembersTable> {
  $$CircleMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get roleLabel =>
      $composableBuilder(column: $table.roleLabel, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  $$CirclesTableAnnotationComposer get circleId {
    final $$CirclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableAnnotationComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CircleMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CircleMembersTable,
          CircleMember,
          $$CircleMembersTableFilterComposer,
          $$CircleMembersTableOrderingComposer,
          $$CircleMembersTableAnnotationComposer,
          $$CircleMembersTableCreateCompanionBuilder,
          $$CircleMembersTableUpdateCompanionBuilder,
          (CircleMember, $$CircleMembersTableReferences),
          CircleMember,
          PrefetchHooks Function({bool circleId, bool userId})
        > {
  $$CircleMembersTableTableManager(_$AppDatabase db, $CircleMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CircleMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$CircleMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CircleMembersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> circleId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> roleLabel = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CircleMembersCompanion(
                circleId: circleId,
                userId: userId,
                role: role,
                roleLabel: roleLabel,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String circleId,
                required String userId,
                required String role,
                Value<String?> roleLabel = const Value.absent(),
                required DateTime joinedAt,
                Value<int> rowid = const Value.absent(),
              }) => CircleMembersCompanion.insert(
                circleId: circleId,
                userId: userId,
                role: role,
                roleLabel: roleLabel,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$CircleMembersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({circleId = false, userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (circleId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.circleId,
                            referencedTable: $$CircleMembersTableReferences
                                ._circleIdTable(db),
                            referencedColumn:
                                $$CircleMembersTableReferences
                                    ._circleIdTable(db)
                                    .id,
                          )
                          as T;
                }
                if (userId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.userId,
                            referencedTable: $$CircleMembersTableReferences
                                ._userIdTable(db),
                            referencedColumn:
                                $$CircleMembersTableReferences
                                    ._userIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CircleMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CircleMembersTable,
      CircleMember,
      $$CircleMembersTableFilterComposer,
      $$CircleMembersTableOrderingComposer,
      $$CircleMembersTableAnnotationComposer,
      $$CircleMembersTableCreateCompanionBuilder,
      $$CircleMembersTableUpdateCompanionBuilder,
      (CircleMember, $$CircleMembersTableReferences),
      CircleMember,
      PrefetchHooks Function({bool circleId, bool userId})
    >;
typedef $$MomentsTableCreateCompanionBuilder =
    MomentsCompanion Function({
      required String id,
      required String circleId,
      required String authorId,
      required String content,
      Value<String> mediaType,
      Value<String> mediaUrls,
      required DateTime timestamp,
      Value<String?> contextTags,
      Value<String?> location,
      Value<bool> isFavorite,
      Value<String?> futureMessage,
      Value<bool> isSharedToWorld,
      Value<String?> worldTopic,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncStatus,
      Value<int> serverVersion,
      Value<DateTime?> lastSyncAt,
      Value<int> rowid,
    });
typedef $$MomentsTableUpdateCompanionBuilder =
    MomentsCompanion Function({
      Value<String> id,
      Value<String> circleId,
      Value<String> authorId,
      Value<String> content,
      Value<String> mediaType,
      Value<String> mediaUrls,
      Value<DateTime> timestamp,
      Value<String?> contextTags,
      Value<String?> location,
      Value<bool> isFavorite,
      Value<String?> futureMessage,
      Value<bool> isSharedToWorld,
      Value<String?> worldTopic,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncStatus,
      Value<int> serverVersion,
      Value<DateTime?> lastSyncAt,
      Value<int> rowid,
    });

final class $$MomentsTableReferences
    extends BaseReferences<_$AppDatabase, $MomentsTable, Moment> {
  $$MomentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CirclesTable _circleIdTable(_$AppDatabase db) => db.circles
      .createAlias($_aliasNameGenerator(db.moments.circleId, db.circles.id));

  $$CirclesTableProcessedTableManager get circleId {
    final $_column = $_itemColumn<String>('circle_id')!;

    final manager = $$CirclesTableTableManager(
      $_db,
      $_db.circles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_circleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _authorIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.moments.authorId, db.users.id),
  );

  $$UsersTableProcessedTableManager get authorId {
    final $_column = $_itemColumn<String>('author_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_authorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MomentsTableFilterComposer
    extends Composer<_$AppDatabase, $MomentsTable> {
  $$MomentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaUrls => $composableBuilder(
    column: $table.mediaUrls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextTags => $composableBuilder(
    column: $table.contextTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get futureMessage => $composableBuilder(
    column: $table.futureMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSharedToWorld => $composableBuilder(
    column: $table.isSharedToWorld,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get worldTopic => $composableBuilder(
    column: $table.worldTopic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CirclesTableFilterComposer get circleId {
    final $$CirclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableFilterComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get authorId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MomentsTableOrderingComposer
    extends Composer<_$AppDatabase, $MomentsTable> {
  $$MomentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaUrls => $composableBuilder(
    column: $table.mediaUrls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextTags => $composableBuilder(
    column: $table.contextTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get futureMessage => $composableBuilder(
    column: $table.futureMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSharedToWorld => $composableBuilder(
    column: $table.isSharedToWorld,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get worldTopic => $composableBuilder(
    column: $table.worldTopic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CirclesTableOrderingComposer get circleId {
    final $$CirclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableOrderingComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get authorId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MomentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MomentsTable> {
  $$MomentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get mediaUrls =>
      $composableBuilder(column: $table.mediaUrls, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get contextTags => $composableBuilder(
    column: $table.contextTags,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get futureMessage => $composableBuilder(
    column: $table.futureMessage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSharedToWorld => $composableBuilder(
    column: $table.isSharedToWorld,
    builder: (column) => column,
  );

  GeneratedColumn<String> get worldTopic => $composableBuilder(
    column: $table.worldTopic,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  $$CirclesTableAnnotationComposer get circleId {
    final $$CirclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableAnnotationComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get authorId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MomentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MomentsTable,
          Moment,
          $$MomentsTableFilterComposer,
          $$MomentsTableOrderingComposer,
          $$MomentsTableAnnotationComposer,
          $$MomentsTableCreateCompanionBuilder,
          $$MomentsTableUpdateCompanionBuilder,
          (Moment, $$MomentsTableReferences),
          Moment,
          PrefetchHooks Function({bool circleId, bool authorId})
        > {
  $$MomentsTableTableManager(_$AppDatabase db, $MomentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MomentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MomentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MomentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> circleId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> mediaUrls = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> contextTags = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> futureMessage = const Value.absent(),
                Value<bool> isSharedToWorld = const Value.absent(),
                Value<String?> worldTopic = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MomentsCompanion(
                id: id,
                circleId: circleId,
                authorId: authorId,
                content: content,
                mediaType: mediaType,
                mediaUrls: mediaUrls,
                timestamp: timestamp,
                contextTags: contextTags,
                location: location,
                isFavorite: isFavorite,
                futureMessage: futureMessage,
                isSharedToWorld: isSharedToWorld,
                worldTopic: worldTopic,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                serverVersion: serverVersion,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String circleId,
                required String authorId,
                required String content,
                Value<String> mediaType = const Value.absent(),
                Value<String> mediaUrls = const Value.absent(),
                required DateTime timestamp,
                Value<String?> contextTags = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<String?> futureMessage = const Value.absent(),
                Value<bool> isSharedToWorld = const Value.absent(),
                Value<String?> worldTopic = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MomentsCompanion.insert(
                id: id,
                circleId: circleId,
                authorId: authorId,
                content: content,
                mediaType: mediaType,
                mediaUrls: mediaUrls,
                timestamp: timestamp,
                contextTags: contextTags,
                location: location,
                isFavorite: isFavorite,
                futureMessage: futureMessage,
                isSharedToWorld: isSharedToWorld,
                worldTopic: worldTopic,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                serverVersion: serverVersion,
                lastSyncAt: lastSyncAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$MomentsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({circleId = false, authorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (circleId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.circleId,
                            referencedTable: $$MomentsTableReferences
                                ._circleIdTable(db),
                            referencedColumn:
                                $$MomentsTableReferences._circleIdTable(db).id,
                          )
                          as T;
                }
                if (authorId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.authorId,
                            referencedTable: $$MomentsTableReferences
                                ._authorIdTable(db),
                            referencedColumn:
                                $$MomentsTableReferences._authorIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MomentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MomentsTable,
      Moment,
      $$MomentsTableFilterComposer,
      $$MomentsTableOrderingComposer,
      $$MomentsTableAnnotationComposer,
      $$MomentsTableCreateCompanionBuilder,
      $$MomentsTableUpdateCompanionBuilder,
      (Moment, $$MomentsTableReferences),
      Moment,
      PrefetchHooks Function({bool circleId, bool authorId})
    >;
typedef $$MomentCacheInfoTableCreateCompanionBuilder =
    MomentCacheInfoCompanion Function({
      required String circleId,
      required String filterHash,
      Value<int> currentPage,
      Value<int> totalItems,
      Value<bool> hasMore,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$MomentCacheInfoTableUpdateCompanionBuilder =
    MomentCacheInfoCompanion Function({
      Value<String> circleId,
      Value<String> filterHash,
      Value<int> currentPage,
      Value<int> totalItems,
      Value<bool> hasMore,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$MomentCacheInfoTableFilterComposer
    extends Composer<_$AppDatabase, $MomentCacheInfoTable> {
  $$MomentCacheInfoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get circleId => $composableBuilder(
    column: $table.circleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterHash => $composableBuilder(
    column: $table.filterHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalItems => $composableBuilder(
    column: $table.totalItems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasMore => $composableBuilder(
    column: $table.hasMore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MomentCacheInfoTableOrderingComposer
    extends Composer<_$AppDatabase, $MomentCacheInfoTable> {
  $$MomentCacheInfoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get circleId => $composableBuilder(
    column: $table.circleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterHash => $composableBuilder(
    column: $table.filterHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalItems => $composableBuilder(
    column: $table.totalItems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasMore => $composableBuilder(
    column: $table.hasMore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MomentCacheInfoTableAnnotationComposer
    extends Composer<_$AppDatabase, $MomentCacheInfoTable> {
  $$MomentCacheInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get circleId =>
      $composableBuilder(column: $table.circleId, builder: (column) => column);

  GeneratedColumn<String> get filterHash => $composableBuilder(
    column: $table.filterHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalItems => $composableBuilder(
    column: $table.totalItems,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasMore =>
      $composableBuilder(column: $table.hasMore, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$MomentCacheInfoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MomentCacheInfoTable,
          MomentCacheInfoData,
          $$MomentCacheInfoTableFilterComposer,
          $$MomentCacheInfoTableOrderingComposer,
          $$MomentCacheInfoTableAnnotationComposer,
          $$MomentCacheInfoTableCreateCompanionBuilder,
          $$MomentCacheInfoTableUpdateCompanionBuilder,
          (
            MomentCacheInfoData,
            BaseReferences<
              _$AppDatabase,
              $MomentCacheInfoTable,
              MomentCacheInfoData
            >,
          ),
          MomentCacheInfoData,
          PrefetchHooks Function()
        > {
  $$MomentCacheInfoTableTableManager(
    _$AppDatabase db,
    $MomentCacheInfoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$MomentCacheInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MomentCacheInfoTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$MomentCacheInfoTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> circleId = const Value.absent(),
                Value<String> filterHash = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<int> totalItems = const Value.absent(),
                Value<bool> hasMore = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MomentCacheInfoCompanion(
                circleId: circleId,
                filterHash: filterHash,
                currentPage: currentPage,
                totalItems: totalItems,
                hasMore: hasMore,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String circleId,
                required String filterHash,
                Value<int> currentPage = const Value.absent(),
                Value<int> totalItems = const Value.absent(),
                Value<bool> hasMore = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => MomentCacheInfoCompanion.insert(
                circleId: circleId,
                filterHash: filterHash,
                currentPage: currentPage,
                totalItems: totalItems,
                hasMore: hasMore,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MomentCacheInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MomentCacheInfoTable,
      MomentCacheInfoData,
      $$MomentCacheInfoTableFilterComposer,
      $$MomentCacheInfoTableOrderingComposer,
      $$MomentCacheInfoTableAnnotationComposer,
      $$MomentCacheInfoTableCreateCompanionBuilder,
      $$MomentCacheInfoTableUpdateCompanionBuilder,
      (
        MomentCacheInfoData,
        BaseReferences<
          _$AppDatabase,
          $MomentCacheInfoTable,
          MomentCacheInfoData
        >,
      ),
      MomentCacheInfoData,
      PrefetchHooks Function()
    >;
typedef $$LettersTableCreateCompanionBuilder =
    LettersCompanion Function({
      required String id,
      required String circleId,
      required String authorId,
      required String title,
      Value<String> preview,
      Value<String?> content,
      Value<String> status,
      Value<String> type,
      required String recipient,
      Value<DateTime?> unlockDate,
      required DateTime createdAt,
      Value<DateTime?> sealedAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncStatus,
      Value<int> serverVersion,
      Value<int> rowid,
    });
typedef $$LettersTableUpdateCompanionBuilder =
    LettersCompanion Function({
      Value<String> id,
      Value<String> circleId,
      Value<String> authorId,
      Value<String> title,
      Value<String> preview,
      Value<String?> content,
      Value<String> status,
      Value<String> type,
      Value<String> recipient,
      Value<DateTime?> unlockDate,
      Value<DateTime> createdAt,
      Value<DateTime?> sealedAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncStatus,
      Value<int> serverVersion,
      Value<int> rowid,
    });

final class $$LettersTableReferences
    extends BaseReferences<_$AppDatabase, $LettersTable, Letter> {
  $$LettersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CirclesTable _circleIdTable(_$AppDatabase db) => db.circles
      .createAlias($_aliasNameGenerator(db.letters.circleId, db.circles.id));

  $$CirclesTableProcessedTableManager get circleId {
    final $_column = $_itemColumn<String>('circle_id')!;

    final manager = $$CirclesTableTableManager(
      $_db,
      $_db.circles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_circleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _authorIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.letters.authorId, db.users.id),
  );

  $$UsersTableProcessedTableManager get authorId {
    final $_column = $_itemColumn<String>('author_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_authorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LettersTableFilterComposer
    extends Composer<_$AppDatabase, $LettersTable> {
  $$LettersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preview => $composableBuilder(
    column: $table.preview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockDate => $composableBuilder(
    column: $table.unlockDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sealedAt => $composableBuilder(
    column: $table.sealedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  $$CirclesTableFilterComposer get circleId {
    final $$CirclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableFilterComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get authorId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LettersTableOrderingComposer
    extends Composer<_$AppDatabase, $LettersTable> {
  $$LettersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preview => $composableBuilder(
    column: $table.preview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockDate => $composableBuilder(
    column: $table.unlockDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sealedAt => $composableBuilder(
    column: $table.sealedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $$CirclesTableOrderingComposer get circleId {
    final $$CirclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableOrderingComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get authorId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LettersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LettersTable> {
  $$LettersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get preview =>
      $composableBuilder(column: $table.preview, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get recipient =>
      $composableBuilder(column: $table.recipient, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockDate => $composableBuilder(
    column: $table.unlockDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sealedAt =>
      $composableBuilder(column: $table.sealedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  $$CirclesTableAnnotationComposer get circleId {
    final $$CirclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.circleId,
      referencedTable: $db.circles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CirclesTableAnnotationComposer(
            $db: $db,
            $table: $db.circles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get authorId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LettersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LettersTable,
          Letter,
          $$LettersTableFilterComposer,
          $$LettersTableOrderingComposer,
          $$LettersTableAnnotationComposer,
          $$LettersTableCreateCompanionBuilder,
          $$LettersTableUpdateCompanionBuilder,
          (Letter, $$LettersTableReferences),
          Letter,
          PrefetchHooks Function({bool circleId, bool authorId})
        > {
  $$LettersTableTableManager(_$AppDatabase db, $LettersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LettersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LettersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LettersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> circleId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> preview = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> recipient = const Value.absent(),
                Value<DateTime?> unlockDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> sealedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LettersCompanion(
                id: id,
                circleId: circleId,
                authorId: authorId,
                title: title,
                preview: preview,
                content: content,
                status: status,
                type: type,
                recipient: recipient,
                unlockDate: unlockDate,
                createdAt: createdAt,
                sealedAt: sealedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                serverVersion: serverVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String circleId,
                required String authorId,
                required String title,
                Value<String> preview = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> type = const Value.absent(),
                required String recipient,
                Value<DateTime?> unlockDate = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> sealedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncStatus = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LettersCompanion.insert(
                id: id,
                circleId: circleId,
                authorId: authorId,
                title: title,
                preview: preview,
                content: content,
                status: status,
                type: type,
                recipient: recipient,
                unlockDate: unlockDate,
                createdAt: createdAt,
                sealedAt: sealedAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                serverVersion: serverVersion,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$LettersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({circleId = false, authorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (circleId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.circleId,
                            referencedTable: $$LettersTableReferences
                                ._circleIdTable(db),
                            referencedColumn:
                                $$LettersTableReferences._circleIdTable(db).id,
                          )
                          as T;
                }
                if (authorId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.authorId,
                            referencedTable: $$LettersTableReferences
                                ._authorIdTable(db),
                            referencedColumn:
                                $$LettersTableReferences._authorIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LettersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LettersTable,
      Letter,
      $$LettersTableFilterComposer,
      $$LettersTableOrderingComposer,
      $$LettersTableAnnotationComposer,
      $$LettersTableCreateCompanionBuilder,
      $$LettersTableUpdateCompanionBuilder,
      (Letter, $$LettersTableReferences),
      Letter,
      PrefetchHooks Function({bool circleId, bool authorId})
    >;
typedef $$SyncLogTableCreateCompanionBuilder =
    SyncLogCompanion Function({
      Value<int> id,
      required String circleId,
      required String entityType,
      required String entityId,
      required String action,
      Value<String?> data,
      required DateTime timestamp,
      Value<int> attempts,
      Value<String?> lastError,
      Value<bool> isSynced,
      Value<DateTime?> syncedAt,
    });
typedef $$SyncLogTableUpdateCompanionBuilder =
    SyncLogCompanion Function({
      Value<int> id,
      Value<String> circleId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> action,
      Value<String?> data,
      Value<DateTime> timestamp,
      Value<int> attempts,
      Value<String?> lastError,
      Value<bool> isSynced,
      Value<DateTime?> syncedAt,
    });

class $$SyncLogTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get circleId => $composableBuilder(
    column: $table.circleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLogTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get circleId => $composableBuilder(
    column: $table.circleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get circleId =>
      $composableBuilder(column: $table.circleId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SyncLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLogTable,
          SyncLogData,
          $$SyncLogTableFilterComposer,
          $$SyncLogTableOrderingComposer,
          $$SyncLogTableAnnotationComposer,
          $$SyncLogTableCreateCompanionBuilder,
          $$SyncLogTableUpdateCompanionBuilder,
          (
            SyncLogData,
            BaseReferences<_$AppDatabase, $SyncLogTable, SyncLogData>,
          ),
          SyncLogData,
          PrefetchHooks Function()
        > {
  $$SyncLogTableTableManager(_$AppDatabase db, $SyncLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> circleId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => SyncLogCompanion(
                id: id,
                circleId: circleId,
                entityType: entityType,
                entityId: entityId,
                action: action,
                data: data,
                timestamp: timestamp,
                attempts: attempts,
                lastError: lastError,
                isSynced: isSynced,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String circleId,
                required String entityType,
                required String entityId,
                required String action,
                Value<String?> data = const Value.absent(),
                required DateTime timestamp,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => SyncLogCompanion.insert(
                id: id,
                circleId: circleId,
                entityType: entityType,
                entityId: entityId,
                action: action,
                data: data,
                timestamp: timestamp,
                attempts: attempts,
                lastError: lastError,
                isSynced: isSynced,
                syncedAt: syncedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLogTable,
      SyncLogData,
      $$SyncLogTableFilterComposer,
      $$SyncLogTableOrderingComposer,
      $$SyncLogTableAnnotationComposer,
      $$SyncLogTableCreateCompanionBuilder,
      $$SyncLogTableUpdateCompanionBuilder,
      (SyncLogData, BaseReferences<_$AppDatabase, $SyncLogTable, SyncLogData>),
      SyncLogData,
      PrefetchHooks Function()
    >;
typedef $$SyncStatusTableCreateCompanionBuilder =
    SyncStatusCompanion Function({
      required String circleId,
      Value<DateTime?> lastFullSync,
      Value<DateTime?> lastIncrementalSync,
      Value<int> pendingChanges,
      Value<bool> isSyncing,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncStatusTableUpdateCompanionBuilder =
    SyncStatusCompanion Function({
      Value<String> circleId,
      Value<DateTime?> lastFullSync,
      Value<DateTime?> lastIncrementalSync,
      Value<int> pendingChanges,
      Value<bool> isSyncing,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncStatusTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatusTable> {
  $$SyncStatusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get circleId => $composableBuilder(
    column: $table.circleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFullSync => $composableBuilder(
    column: $table.lastFullSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastIncrementalSync => $composableBuilder(
    column: $table.lastIncrementalSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingChanges => $composableBuilder(
    column: $table.pendingChanges,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSyncing => $composableBuilder(
    column: $table.isSyncing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatusTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatusTable> {
  $$SyncStatusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get circleId => $composableBuilder(
    column: $table.circleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFullSync => $composableBuilder(
    column: $table.lastFullSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastIncrementalSync => $composableBuilder(
    column: $table.lastIncrementalSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingChanges => $composableBuilder(
    column: $table.pendingChanges,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSyncing => $composableBuilder(
    column: $table.isSyncing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatusTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatusTable> {
  $$SyncStatusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get circleId =>
      $composableBuilder(column: $table.circleId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFullSync => $composableBuilder(
    column: $table.lastFullSync,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastIncrementalSync => $composableBuilder(
    column: $table.lastIncrementalSync,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingChanges => $composableBuilder(
    column: $table.pendingChanges,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSyncing =>
      $composableBuilder(column: $table.isSyncing, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncStatusTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatusTable,
          SyncStatusData,
          $$SyncStatusTableFilterComposer,
          $$SyncStatusTableOrderingComposer,
          $$SyncStatusTableAnnotationComposer,
          $$SyncStatusTableCreateCompanionBuilder,
          $$SyncStatusTableUpdateCompanionBuilder,
          (
            SyncStatusData,
            BaseReferences<_$AppDatabase, $SyncStatusTable, SyncStatusData>,
          ),
          SyncStatusData,
          PrefetchHooks Function()
        > {
  $$SyncStatusTableTableManager(_$AppDatabase db, $SyncStatusTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncStatusTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncStatusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncStatusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> circleId = const Value.absent(),
                Value<DateTime?> lastFullSync = const Value.absent(),
                Value<DateTime?> lastIncrementalSync = const Value.absent(),
                Value<int> pendingChanges = const Value.absent(),
                Value<bool> isSyncing = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatusCompanion(
                circleId: circleId,
                lastFullSync: lastFullSync,
                lastIncrementalSync: lastIncrementalSync,
                pendingChanges: pendingChanges,
                isSyncing: isSyncing,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String circleId,
                Value<DateTime?> lastFullSync = const Value.absent(),
                Value<DateTime?> lastIncrementalSync = const Value.absent(),
                Value<int> pendingChanges = const Value.absent(),
                Value<bool> isSyncing = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatusCompanion.insert(
                circleId: circleId,
                lastFullSync: lastFullSync,
                lastIncrementalSync: lastIncrementalSync,
                pendingChanges: pendingChanges,
                isSyncing: isSyncing,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatusTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatusTable,
      SyncStatusData,
      $$SyncStatusTableFilterComposer,
      $$SyncStatusTableOrderingComposer,
      $$SyncStatusTableAnnotationComposer,
      $$SyncStatusTableCreateCompanionBuilder,
      $$SyncStatusTableUpdateCompanionBuilder,
      (
        SyncStatusData,
        BaseReferences<_$AppDatabase, $SyncStatusTable, SyncStatusData>,
      ),
      SyncStatusData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$CirclesTableTableManager get circles =>
      $$CirclesTableTableManager(_db, _db.circles);
  $$CircleMembersTableTableManager get circleMembers =>
      $$CircleMembersTableTableManager(_db, _db.circleMembers);
  $$MomentsTableTableManager get moments =>
      $$MomentsTableTableManager(_db, _db.moments);
  $$MomentCacheInfoTableTableManager get momentCacheInfo =>
      $$MomentCacheInfoTableTableManager(_db, _db.momentCacheInfo);
  $$LettersTableTableManager get letters =>
      $$LettersTableTableManager(_db, _db.letters);
  $$SyncLogTableTableManager get syncLog =>
      $$SyncLogTableTableManager(_db, _db.syncLog);
  $$SyncStatusTableTableManager get syncStatus =>
      $$SyncStatusTableTableManager(_db, _db.syncStatus);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
