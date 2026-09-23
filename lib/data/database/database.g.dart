// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avataUrlMeta = const VerificationMeta(
    'avataUrl',
  );
  @override
  late final GeneratedColumn<String> avataUrl = GeneratedColumn<String>(
    'avata_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sleepPastCountMeta = const VerificationMeta(
    'sleepPastCount',
  );
  @override
  late final GeneratedColumn<int> sleepPastCount = GeneratedColumn<int>(
    'sleep_past_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lateCountMeta = const VerificationMeta(
    'lateCount',
  );
  @override
  late final GeneratedColumn<int> lateCount = GeneratedColumn<int>(
    'late_count',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    avataUrl,
    sleepPastCount,
    lateCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('avata_url')) {
      context.handle(
        _avataUrlMeta,
        avataUrl.isAcceptableOrUnknown(data['avata_url']!, _avataUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_avataUrlMeta);
    }
    if (data.containsKey('sleep_past_count')) {
      context.handle(
        _sleepPastCountMeta,
        sleepPastCount.isAcceptableOrUnknown(
          data['sleep_past_count']!,
          _sleepPastCountMeta,
        ),
      );
    }
    if (data.containsKey('late_count')) {
      context.handle(
        _lateCountMeta,
        lateCount.isAcceptableOrUnknown(data['late_count']!, _lateCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      avataUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avata_url'],
      )!,
      sleepPastCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_past_count'],
      )!,
      lateCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}late_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String nickname;
  final String avataUrl;
  final int sleepPastCount;
  final int lateCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Profile({
    required this.id,
    required this.nickname,
    required this.avataUrl,
    required this.sleepPastCount,
    required this.lateCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nickname'] = Variable<String>(nickname);
    map['avata_url'] = Variable<String>(avataUrl);
    map['sleep_past_count'] = Variable<int>(sleepPastCount);
    map['late_count'] = Variable<int>(lateCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      nickname: Value(nickname),
      avataUrl: Value(avataUrl),
      sleepPastCount: Value(sleepPastCount),
      lateCount: Value(lateCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      avataUrl: serializer.fromJson<String>(json['avataUrl']),
      sleepPastCount: serializer.fromJson<int>(json['sleepPastCount']),
      lateCount: serializer.fromJson<int>(json['lateCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nickname': serializer.toJson<String>(nickname),
      'avataUrl': serializer.toJson<String>(avataUrl),
      'sleepPastCount': serializer.toJson<int>(sleepPastCount),
      'lateCount': serializer.toJson<int>(lateCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Profile copyWith({
    String? id,
    String? nickname,
    String? avataUrl,
    int? sleepPastCount,
    int? lateCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Profile(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    avataUrl: avataUrl ?? this.avataUrl,
    sleepPastCount: sleepPastCount ?? this.sleepPastCount,
    lateCount: lateCount ?? this.lateCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      avataUrl: data.avataUrl.present ? data.avataUrl.value : this.avataUrl,
      sleepPastCount: data.sleepPastCount.present
          ? data.sleepPastCount.value
          : this.sleepPastCount,
      lateCount: data.lateCount.present ? data.lateCount.value : this.lateCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avataUrl: $avataUrl, ')
          ..write('sleepPastCount: $sleepPastCount, ')
          ..write('lateCount: $lateCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nickname,
    avataUrl,
    sleepPastCount,
    lateCount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.avataUrl == this.avataUrl &&
          other.sleepPastCount == this.sleepPastCount &&
          other.lateCount == this.lateCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String> nickname;
  final Value<String> avataUrl;
  final Value<int> sleepPastCount;
  final Value<int> lateCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avataUrl = const Value.absent(),
    this.sleepPastCount = const Value.absent(),
    this.lateCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required String nickname,
    required String avataUrl,
    this.sleepPastCount = const Value.absent(),
    this.lateCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nickname = Value(nickname),
       avataUrl = Value(avataUrl);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? nickname,
    Expression<String>? avataUrl,
    Expression<int>? sleepPastCount,
    Expression<int>? lateCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (avataUrl != null) 'avata_url': avataUrl,
      if (sleepPastCount != null) 'sleep_past_count': sleepPastCount,
      if (lateCount != null) 'late_count': lateCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? nickname,
    Value<String>? avataUrl,
    Value<int>? sleepPastCount,
    Value<int>? lateCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avataUrl: avataUrl ?? this.avataUrl,
      sleepPastCount: sleepPastCount ?? this.sleepPastCount,
      lateCount: lateCount ?? this.lateCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avataUrl.present) {
      map['avata_url'] = Variable<String>(avataUrl.value);
    }
    if (sleepPastCount.present) {
      map['sleep_past_count'] = Variable<int>(sleepPastCount.value);
    }
    if (lateCount.present) {
      map['late_count'] = Variable<int>(lateCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('avataUrl: $avataUrl, ')
          ..write('sleepPastCount: $sleepPastCount, ')
          ..write('lateCount: $lateCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invitationCodeMeta = const VerificationMeta(
    'invitationCode',
  );
  @override
  late final GeneratedColumn<String> invitationCode = GeneratedColumn<String>(
    'invitation_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invitationCode,
    groupName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<Group> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invitation_code')) {
      context.handle(
        _invitationCodeMeta,
        invitationCode.isAcceptableOrUnknown(
          data['invitation_code']!,
          _invitationCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invitationCodeMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      invitationCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invitation_code'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final String id;
  final String invitationCode;
  final String groupName;
  final DateTime createdAt;
  const Group({
    required this.id,
    required this.invitationCode,
    required this.groupName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invitation_code'] = Variable<String>(invitationCode);
    map['group_name'] = Variable<String>(groupName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      invitationCode: Value(invitationCode),
      groupName: Value(groupName),
      createdAt: Value(createdAt),
    );
  }

  factory Group.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<String>(json['id']),
      invitationCode: serializer.fromJson<String>(json['invitationCode']),
      groupName: serializer.fromJson<String>(json['groupName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invitationCode': serializer.toJson<String>(invitationCode),
      'groupName': serializer.toJson<String>(groupName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Group copyWith({
    String? id,
    String? invitationCode,
    String? groupName,
    DateTime? createdAt,
  }) => Group(
    id: id ?? this.id,
    invitationCode: invitationCode ?? this.invitationCode,
    groupName: groupName ?? this.groupName,
    createdAt: createdAt ?? this.createdAt,
  );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      invitationCode: data.invitationCode.present
          ? data.invitationCode.value
          : this.invitationCode,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('invitationCode: $invitationCode, ')
          ..write('groupName: $groupName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, invitationCode, groupName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.invitationCode == this.invitationCode &&
          other.groupName == this.groupName &&
          other.createdAt == this.createdAt);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<String> id;
  final Value<String> invitationCode;
  final Value<String> groupName;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.invitationCode = const Value.absent(),
    this.groupName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    required String invitationCode,
    required String groupName,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       invitationCode = Value(invitationCode),
       groupName = Value(groupName);
  static Insertable<Group> custom({
    Expression<String>? id,
    Expression<String>? invitationCode,
    Expression<String>? groupName,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invitationCode != null) 'invitation_code': invitationCode,
      if (groupName != null) 'group_name': groupName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? invitationCode,
    Value<String>? groupName,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GroupsCompanion(
      id: id ?? this.id,
      invitationCode: invitationCode ?? this.invitationCode,
      groupName: groupName ?? this.groupName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invitationCode.present) {
      map['invitation_code'] = Variable<String>(invitationCode.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('invitationCode: $invitationCode, ')
          ..write('groupName: $groupName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupMembershipsTable extends GroupMemberships
    with TableInfo<$GroupMembershipsTable, GroupMembership> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id)',
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
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, groupId, userId, role, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupMembership> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
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
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupMembership map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMembership(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
    );
  }

  @override
  $GroupMembershipsTable createAlias(String alias) {
    return $GroupMembershipsTable(attachedDatabase, alias);
  }
}

class GroupMembership extends DataClass implements Insertable<GroupMembership> {
  final String id;
  final String groupId;
  final String userId;
  final int role;
  final DateTime joinedAt;
  const GroupMembership({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<int>(role);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  GroupMembershipsCompanion toCompanion(bool nullToAbsent) {
    return GroupMembershipsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      userId: Value(userId),
      role: Value(role),
      joinedAt: Value(joinedAt),
    );
  }

  factory GroupMembership.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMembership(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<int>(json['role']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<int>(role),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  GroupMembership copyWith({
    String? id,
    String? groupId,
    String? userId,
    int? role,
    DateTime? joinedAt,
  }) => GroupMembership(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    joinedAt: joinedAt ?? this.joinedAt,
  );
  GroupMembership copyWithCompanion(GroupMembershipsCompanion data) {
    return GroupMembership(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembership(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, userId, role, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMembership &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt);
}

class GroupMembershipsCompanion extends UpdateCompanion<GroupMembership> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> userId;
  final Value<int> role;
  final Value<DateTime> joinedAt;
  final Value<int> rowid;
  const GroupMembershipsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupMembershipsCompanion.insert({
    required String id,
    required String groupId,
    required String userId,
    required int role,
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       userId = Value(userId),
       role = Value(role);
  static Insertable<GroupMembership> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? userId,
    Expression<int>? role,
    Expression<DateTime>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupMembershipsCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? userId,
    Value<int>? role,
    Value<DateTime>? joinedAt,
    Value<int>? rowid,
  }) {
    return GroupMembershipsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
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
    return (StringBuffer('GroupMembershipsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES "groups" (id)',
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
  static const VerificationMeta _destinationNameMeta = const VerificationMeta(
    'destinationName',
  );
  @override
  late final GeneratedColumn<String> destinationName = GeneratedColumn<String>(
    'destination_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qrcodeIdMeta = const VerificationMeta(
    'qrcodeId',
  );
  @override
  late final GeneratedColumn<String> qrcodeId = GeneratedColumn<String>(
    'qrcode_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arrivalTimeMeta = const VerificationMeta(
    'arrivalTime',
  );
  @override
  late final GeneratedColumn<DateTime> arrivalTime = GeneratedColumn<DateTime>(
    'arrival_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
    'event_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    title,
    destinationName,
    latitude,
    longitude,
    qrcodeId,
    password,
    arrivalTime,
    status,
    eventDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('destination_name')) {
      context.handle(
        _destinationNameMeta,
        destinationName.isAcceptableOrUnknown(
          data['destination_name']!,
          _destinationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationNameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('qrcode_id')) {
      context.handle(
        _qrcodeIdMeta,
        qrcodeId.isAcceptableOrUnknown(data['qrcode_id']!, _qrcodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_qrcodeIdMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('arrival_time')) {
      context.handle(
        _arrivalTimeMeta,
        arrivalTime.isAcceptableOrUnknown(
          data['arrival_time']!,
          _arrivalTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalTimeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      destinationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      qrcodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qrcode_id'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      arrivalTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrival_time'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String groupId;
  final String title;
  final String destinationName;
  final double latitude;
  final double longitude;
  final String qrcodeId;
  final String password;
  final DateTime arrivalTime;
  final int status;
  final DateTime eventDate;
  final DateTime createdAt;
  const Event({
    required this.id,
    required this.groupId,
    required this.title,
    required this.destinationName,
    required this.latitude,
    required this.longitude,
    required this.qrcodeId,
    required this.password,
    required this.arrivalTime,
    required this.status,
    required this.eventDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['title'] = Variable<String>(title);
    map['destination_name'] = Variable<String>(destinationName);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['qrcode_id'] = Variable<String>(qrcodeId);
    map['password'] = Variable<String>(password);
    map['arrival_time'] = Variable<DateTime>(arrivalTime);
    map['status'] = Variable<int>(status);
    map['event_date'] = Variable<DateTime>(eventDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      title: Value(title),
      destinationName: Value(destinationName),
      latitude: Value(latitude),
      longitude: Value(longitude),
      qrcodeId: Value(qrcodeId),
      password: Value(password),
      arrivalTime: Value(arrivalTime),
      status: Value(status),
      eventDate: Value(eventDate),
      createdAt: Value(createdAt),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      title: serializer.fromJson<String>(json['title']),
      destinationName: serializer.fromJson<String>(json['destinationName']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      qrcodeId: serializer.fromJson<String>(json['qrcodeId']),
      password: serializer.fromJson<String>(json['password']),
      arrivalTime: serializer.fromJson<DateTime>(json['arrivalTime']),
      status: serializer.fromJson<int>(json['status']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'title': serializer.toJson<String>(title),
      'destinationName': serializer.toJson<String>(destinationName),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'qrcodeId': serializer.toJson<String>(qrcodeId),
      'password': serializer.toJson<String>(password),
      'arrivalTime': serializer.toJson<DateTime>(arrivalTime),
      'status': serializer.toJson<int>(status),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Event copyWith({
    String? id,
    String? groupId,
    String? title,
    String? destinationName,
    double? latitude,
    double? longitude,
    String? qrcodeId,
    String? password,
    DateTime? arrivalTime,
    int? status,
    DateTime? eventDate,
    DateTime? createdAt,
  }) => Event(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    title: title ?? this.title,
    destinationName: destinationName ?? this.destinationName,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    qrcodeId: qrcodeId ?? this.qrcodeId,
    password: password ?? this.password,
    arrivalTime: arrivalTime ?? this.arrivalTime,
    status: status ?? this.status,
    eventDate: eventDate ?? this.eventDate,
    createdAt: createdAt ?? this.createdAt,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      title: data.title.present ? data.title.value : this.title,
      destinationName: data.destinationName.present
          ? data.destinationName.value
          : this.destinationName,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      qrcodeId: data.qrcodeId.present ? data.qrcodeId.value : this.qrcodeId,
      password: data.password.present ? data.password.value : this.password,
      arrivalTime: data.arrivalTime.present
          ? data.arrivalTime.value
          : this.arrivalTime,
      status: data.status.present ? data.status.value : this.status,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('title: $title, ')
          ..write('destinationName: $destinationName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('qrcodeId: $qrcodeId, ')
          ..write('password: $password, ')
          ..write('arrivalTime: $arrivalTime, ')
          ..write('status: $status, ')
          ..write('eventDate: $eventDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    title,
    destinationName,
    latitude,
    longitude,
    qrcodeId,
    password,
    arrivalTime,
    status,
    eventDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.title == this.title &&
          other.destinationName == this.destinationName &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.qrcodeId == this.qrcodeId &&
          other.password == this.password &&
          other.arrivalTime == this.arrivalTime &&
          other.status == this.status &&
          other.eventDate == this.eventDate &&
          other.createdAt == this.createdAt);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> title;
  final Value<String> destinationName;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> qrcodeId;
  final Value<String> password;
  final Value<DateTime> arrivalTime;
  final Value<int> status;
  final Value<DateTime> eventDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.title = const Value.absent(),
    this.destinationName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.qrcodeId = const Value.absent(),
    this.password = const Value.absent(),
    this.arrivalTime = const Value.absent(),
    this.status = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String groupId,
    required String title,
    required String destinationName,
    required double latitude,
    required double longitude,
    required String qrcodeId,
    required String password,
    required DateTime arrivalTime,
    required int status,
    required DateTime eventDate,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       title = Value(title),
       destinationName = Value(destinationName),
       latitude = Value(latitude),
       longitude = Value(longitude),
       qrcodeId = Value(qrcodeId),
       password = Value(password),
       arrivalTime = Value(arrivalTime),
       status = Value(status),
       eventDate = Value(eventDate);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? title,
    Expression<String>? destinationName,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? qrcodeId,
    Expression<String>? password,
    Expression<DateTime>? arrivalTime,
    Expression<int>? status,
    Expression<DateTime>? eventDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (title != null) 'title': title,
      if (destinationName != null) 'destination_name': destinationName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (qrcodeId != null) 'qrcode_id': qrcodeId,
      if (password != null) 'password': password,
      if (arrivalTime != null) 'arrival_time': arrivalTime,
      if (status != null) 'status': status,
      if (eventDate != null) 'event_date': eventDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? title,
    Value<String>? destinationName,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? qrcodeId,
    Value<String>? password,
    Value<DateTime>? arrivalTime,
    Value<int>? status,
    Value<DateTime>? eventDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      destinationName: destinationName ?? this.destinationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      qrcodeId: qrcodeId ?? this.qrcodeId,
      password: password ?? this.password,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      status: status ?? this.status,
      eventDate: eventDate ?? this.eventDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (destinationName.present) {
      map['destination_name'] = Variable<String>(destinationName.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (qrcodeId.present) {
      map['qrcode_id'] = Variable<String>(qrcodeId.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (arrivalTime.present) {
      map['arrival_time'] = Variable<DateTime>(arrivalTime.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('title: $title, ')
          ..write('destinationName: $destinationName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('qrcodeId: $qrcodeId, ')
          ..write('password: $password, ')
          ..write('arrivalTime: $arrivalTime, ')
          ..write('status: $status, ')
          ..write('eventDate: $eventDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventReportsTable extends EventReports
    with TableInfo<$EventReportsTable, EventReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES events (id)',
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
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _plannedWakeupTimeMeta = const VerificationMeta(
    'plannedWakeupTime',
  );
  @override
  late final GeneratedColumn<DateTime> plannedWakeupTime =
      GeneratedColumn<DateTime>(
        'planned_wakeup_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _plannedDepartureTimeMeta =
      const VerificationMeta('plannedDepartureTime');
  @override
  late final GeneratedColumn<DateTime> plannedDepartureTime =
      GeneratedColumn<DateTime>(
        'planned_departure_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actualWakeupTimeMeta = const VerificationMeta(
    'actualWakeupTime',
  );
  @override
  late final GeneratedColumn<DateTime> actualWakeupTime =
      GeneratedColumn<DateTime>(
        'actual_wakeup_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actualDepartureTimeMeta =
      const VerificationMeta('actualDepartureTime');
  @override
  late final GeneratedColumn<DateTime> actualDepartureTime =
      GeneratedColumn<DateTime>(
        'actual_departure_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lateReasonMeta = const VerificationMeta(
    'lateReason',
  );
  @override
  late final GeneratedColumn<String> lateReason = GeneratedColumn<String>(
    'late_reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    userId,
    plannedWakeupTime,
    plannedDepartureTime,
    actualWakeupTime,
    actualDepartureTime,
    status,
    lateReason,
    photoUrl,
    latitude,
    longitude,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventReport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('planned_wakeup_time')) {
      context.handle(
        _plannedWakeupTimeMeta,
        plannedWakeupTime.isAcceptableOrUnknown(
          data['planned_wakeup_time']!,
          _plannedWakeupTimeMeta,
        ),
      );
    }
    if (data.containsKey('planned_departure_time')) {
      context.handle(
        _plannedDepartureTimeMeta,
        plannedDepartureTime.isAcceptableOrUnknown(
          data['planned_departure_time']!,
          _plannedDepartureTimeMeta,
        ),
      );
    }
    if (data.containsKey('actual_wakeup_time')) {
      context.handle(
        _actualWakeupTimeMeta,
        actualWakeupTime.isAcceptableOrUnknown(
          data['actual_wakeup_time']!,
          _actualWakeupTimeMeta,
        ),
      );
    }
    if (data.containsKey('actual_departure_time')) {
      context.handle(
        _actualDepartureTimeMeta,
        actualDepartureTime.isAcceptableOrUnknown(
          data['actual_departure_time']!,
          _actualDepartureTimeMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('late_reason')) {
      context.handle(
        _lateReasonMeta,
        lateReason.isAcceptableOrUnknown(data['late_reason']!, _lateReasonMeta),
      );
    } else if (isInserting) {
      context.missing(_lateReasonMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_photoUrlMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      plannedWakeupTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_wakeup_time'],
      ),
      plannedDepartureTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}planned_departure_time'],
      ),
      actualWakeupTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_wakeup_time'],
      ),
      actualDepartureTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_departure_time'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      lateReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}late_reason'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EventReportsTable createAlias(String alias) {
    return $EventReportsTable(attachedDatabase, alias);
  }
}

class EventReport extends DataClass implements Insertable<EventReport> {
  final String id;
  final String eventId;
  final String userId;
  final DateTime? plannedWakeupTime;
  final DateTime? plannedDepartureTime;
  final DateTime? actualWakeupTime;
  final DateTime? actualDepartureTime;
  final int status;
  final String lateReason;
  final String photoUrl;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;
  const EventReport({
    required this.id,
    required this.eventId,
    required this.userId,
    this.plannedWakeupTime,
    this.plannedDepartureTime,
    this.actualWakeupTime,
    this.actualDepartureTime,
    required this.status,
    required this.lateReason,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || plannedWakeupTime != null) {
      map['planned_wakeup_time'] = Variable<DateTime>(plannedWakeupTime);
    }
    if (!nullToAbsent || plannedDepartureTime != null) {
      map['planned_departure_time'] = Variable<DateTime>(plannedDepartureTime);
    }
    if (!nullToAbsent || actualWakeupTime != null) {
      map['actual_wakeup_time'] = Variable<DateTime>(actualWakeupTime);
    }
    if (!nullToAbsent || actualDepartureTime != null) {
      map['actual_departure_time'] = Variable<DateTime>(actualDepartureTime);
    }
    map['status'] = Variable<int>(status);
    map['late_reason'] = Variable<String>(lateReason);
    map['photo_url'] = Variable<String>(photoUrl);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EventReportsCompanion toCompanion(bool nullToAbsent) {
    return EventReportsCompanion(
      id: Value(id),
      eventId: Value(eventId),
      userId: Value(userId),
      plannedWakeupTime: plannedWakeupTime == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedWakeupTime),
      plannedDepartureTime: plannedDepartureTime == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDepartureTime),
      actualWakeupTime: actualWakeupTime == null && nullToAbsent
          ? const Value.absent()
          : Value(actualWakeupTime),
      actualDepartureTime: actualDepartureTime == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDepartureTime),
      status: Value(status),
      lateReason: Value(lateReason),
      photoUrl: Value(photoUrl),
      latitude: Value(latitude),
      longitude: Value(longitude),
      updatedAt: Value(updatedAt),
    );
  }

  factory EventReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventReport(
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      userId: serializer.fromJson<String>(json['userId']),
      plannedWakeupTime: serializer.fromJson<DateTime?>(
        json['plannedWakeupTime'],
      ),
      plannedDepartureTime: serializer.fromJson<DateTime?>(
        json['plannedDepartureTime'],
      ),
      actualWakeupTime: serializer.fromJson<DateTime?>(
        json['actualWakeupTime'],
      ),
      actualDepartureTime: serializer.fromJson<DateTime?>(
        json['actualDepartureTime'],
      ),
      status: serializer.fromJson<int>(json['status']),
      lateReason: serializer.fromJson<String>(json['lateReason']),
      photoUrl: serializer.fromJson<String>(json['photoUrl']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'userId': serializer.toJson<String>(userId),
      'plannedWakeupTime': serializer.toJson<DateTime?>(plannedWakeupTime),
      'plannedDepartureTime': serializer.toJson<DateTime?>(
        plannedDepartureTime,
      ),
      'actualWakeupTime': serializer.toJson<DateTime?>(actualWakeupTime),
      'actualDepartureTime': serializer.toJson<DateTime?>(actualDepartureTime),
      'status': serializer.toJson<int>(status),
      'lateReason': serializer.toJson<String>(lateReason),
      'photoUrl': serializer.toJson<String>(photoUrl),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EventReport copyWith({
    String? id,
    String? eventId,
    String? userId,
    Value<DateTime?> plannedWakeupTime = const Value.absent(),
    Value<DateTime?> plannedDepartureTime = const Value.absent(),
    Value<DateTime?> actualWakeupTime = const Value.absent(),
    Value<DateTime?> actualDepartureTime = const Value.absent(),
    int? status,
    String? lateReason,
    String? photoUrl,
    double? latitude,
    double? longitude,
    DateTime? updatedAt,
  }) => EventReport(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    userId: userId ?? this.userId,
    plannedWakeupTime: plannedWakeupTime.present
        ? plannedWakeupTime.value
        : this.plannedWakeupTime,
    plannedDepartureTime: plannedDepartureTime.present
        ? plannedDepartureTime.value
        : this.plannedDepartureTime,
    actualWakeupTime: actualWakeupTime.present
        ? actualWakeupTime.value
        : this.actualWakeupTime,
    actualDepartureTime: actualDepartureTime.present
        ? actualDepartureTime.value
        : this.actualDepartureTime,
    status: status ?? this.status,
    lateReason: lateReason ?? this.lateReason,
    photoUrl: photoUrl ?? this.photoUrl,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EventReport copyWithCompanion(EventReportsCompanion data) {
    return EventReport(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      userId: data.userId.present ? data.userId.value : this.userId,
      plannedWakeupTime: data.plannedWakeupTime.present
          ? data.plannedWakeupTime.value
          : this.plannedWakeupTime,
      plannedDepartureTime: data.plannedDepartureTime.present
          ? data.plannedDepartureTime.value
          : this.plannedDepartureTime,
      actualWakeupTime: data.actualWakeupTime.present
          ? data.actualWakeupTime.value
          : this.actualWakeupTime,
      actualDepartureTime: data.actualDepartureTime.present
          ? data.actualDepartureTime.value
          : this.actualDepartureTime,
      status: data.status.present ? data.status.value : this.status,
      lateReason: data.lateReason.present
          ? data.lateReason.value
          : this.lateReason,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventReport(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('userId: $userId, ')
          ..write('plannedWakeupTime: $plannedWakeupTime, ')
          ..write('plannedDepartureTime: $plannedDepartureTime, ')
          ..write('actualWakeupTime: $actualWakeupTime, ')
          ..write('actualDepartureTime: $actualDepartureTime, ')
          ..write('status: $status, ')
          ..write('lateReason: $lateReason, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventId,
    userId,
    plannedWakeupTime,
    plannedDepartureTime,
    actualWakeupTime,
    actualDepartureTime,
    status,
    lateReason,
    photoUrl,
    latitude,
    longitude,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventReport &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.userId == this.userId &&
          other.plannedWakeupTime == this.plannedWakeupTime &&
          other.plannedDepartureTime == this.plannedDepartureTime &&
          other.actualWakeupTime == this.actualWakeupTime &&
          other.actualDepartureTime == this.actualDepartureTime &&
          other.status == this.status &&
          other.lateReason == this.lateReason &&
          other.photoUrl == this.photoUrl &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.updatedAt == this.updatedAt);
}

class EventReportsCompanion extends UpdateCompanion<EventReport> {
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> userId;
  final Value<DateTime?> plannedWakeupTime;
  final Value<DateTime?> plannedDepartureTime;
  final Value<DateTime?> actualWakeupTime;
  final Value<DateTime?> actualDepartureTime;
  final Value<int> status;
  final Value<String> lateReason;
  final Value<String> photoUrl;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EventReportsCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.userId = const Value.absent(),
    this.plannedWakeupTime = const Value.absent(),
    this.plannedDepartureTime = const Value.absent(),
    this.actualWakeupTime = const Value.absent(),
    this.actualDepartureTime = const Value.absent(),
    this.status = const Value.absent(),
    this.lateReason = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventReportsCompanion.insert({
    required String id,
    required String eventId,
    required String userId,
    this.plannedWakeupTime = const Value.absent(),
    this.plannedDepartureTime = const Value.absent(),
    this.actualWakeupTime = const Value.absent(),
    this.actualDepartureTime = const Value.absent(),
    required int status,
    required String lateReason,
    required String photoUrl,
    required double latitude,
    required double longitude,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       userId = Value(userId),
       status = Value(status),
       lateReason = Value(lateReason),
       photoUrl = Value(photoUrl),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<EventReport> custom({
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? userId,
    Expression<DateTime>? plannedWakeupTime,
    Expression<DateTime>? plannedDepartureTime,
    Expression<DateTime>? actualWakeupTime,
    Expression<DateTime>? actualDepartureTime,
    Expression<int>? status,
    Expression<String>? lateReason,
    Expression<String>? photoUrl,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (userId != null) 'user_id': userId,
      if (plannedWakeupTime != null) 'planned_wakeup_time': plannedWakeupTime,
      if (plannedDepartureTime != null)
        'planned_departure_time': plannedDepartureTime,
      if (actualWakeupTime != null) 'actual_wakeup_time': actualWakeupTime,
      if (actualDepartureTime != null)
        'actual_departure_time': actualDepartureTime,
      if (status != null) 'status': status,
      if (lateReason != null) 'late_reason': lateReason,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventReportsCompanion copyWith({
    Value<String>? id,
    Value<String>? eventId,
    Value<String>? userId,
    Value<DateTime?>? plannedWakeupTime,
    Value<DateTime?>? plannedDepartureTime,
    Value<DateTime?>? actualWakeupTime,
    Value<DateTime?>? actualDepartureTime,
    Value<int>? status,
    Value<String>? lateReason,
    Value<String>? photoUrl,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EventReportsCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      plannedWakeupTime: plannedWakeupTime ?? this.plannedWakeupTime,
      plannedDepartureTime: plannedDepartureTime ?? this.plannedDepartureTime,
      actualWakeupTime: actualWakeupTime ?? this.actualWakeupTime,
      actualDepartureTime: actualDepartureTime ?? this.actualDepartureTime,
      status: status ?? this.status,
      lateReason: lateReason ?? this.lateReason,
      photoUrl: photoUrl ?? this.photoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (plannedWakeupTime.present) {
      map['planned_wakeup_time'] = Variable<DateTime>(plannedWakeupTime.value);
    }
    if (plannedDepartureTime.present) {
      map['planned_departure_time'] = Variable<DateTime>(
        plannedDepartureTime.value,
      );
    }
    if (actualWakeupTime.present) {
      map['actual_wakeup_time'] = Variable<DateTime>(actualWakeupTime.value);
    }
    if (actualDepartureTime.present) {
      map['actual_departure_time'] = Variable<DateTime>(
        actualDepartureTime.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (lateReason.present) {
      map['late_reason'] = Variable<String>(lateReason.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
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
    return (StringBuffer('EventReportsCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('userId: $userId, ')
          ..write('plannedWakeupTime: $plannedWakeupTime, ')
          ..write('plannedDepartureTime: $plannedDepartureTime, ')
          ..write('actualWakeupTime: $actualWakeupTime, ')
          ..write('actualDepartureTime: $actualDepartureTime, ')
          ..write('status: $status, ')
          ..write('lateReason: $lateReason, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AwakeDatabase extends GeneratedDatabase {
  _$AwakeDatabase(QueryExecutor e) : super(e);
  $AwakeDatabaseManager get managers => $AwakeDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupMembershipsTable groupMemberships = $GroupMembershipsTable(
    this,
  );
  late final $EventsTable events = $EventsTable(this);
  late final $EventReportsTable eventReports = $EventReportsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    groups,
    groupMemberships,
    events,
    eventReports,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String id,
      required String nickname,
      required String avataUrl,
      Value<int> sleepPastCount,
      Value<int> lateCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<String> nickname,
      Value<String> avataUrl,
      Value<int> sleepPastCount,
      Value<int> lateCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$AwakeDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembershipsTable, List<GroupMembership>>
  _groupMembershipsRefsTable(_$AwakeDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groupMemberships,
        aliasName: $_aliasNameGenerator(
          db.profiles.id,
          db.groupMemberships.userId,
        ),
      );

  $$GroupMembershipsTableProcessedTableManager get groupMembershipsRefs {
    final manager = $$GroupMembershipsTableTableManager(
      $_db,
      $_db.groupMemberships,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupMembershipsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventReportsTable, List<EventReport>>
  _eventReportsRefsTable(_$AwakeDatabase db) => MultiTypedResultKey.fromTable(
    db.eventReports,
    aliasName: $_aliasNameGenerator(db.profiles.id, db.eventReports.userId),
  );

  $$EventReportsTableProcessedTableManager get eventReportsRefs {
    final manager = $$EventReportsTableTableManager(
      $_db,
      $_db.eventReports,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventReportsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AwakeDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avataUrl => $composableBuilder(
    column: $table.avataUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepPastCount => $composableBuilder(
    column: $table.sleepPastCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lateCount => $composableBuilder(
    column: $table.lateCount,
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

  Expression<bool> groupMembershipsRefs(
    Expression<bool> Function($$GroupMembershipsTableFilterComposer f) f,
  ) {
    final $$GroupMembershipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMemberships,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembershipsTableFilterComposer(
            $db: $db,
            $table: $db.groupMemberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventReportsRefs(
    Expression<bool> Function($$EventReportsTableFilterComposer f) f,
  ) {
    final $$EventReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventReports,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventReportsTableFilterComposer(
            $db: $db,
            $table: $db.eventReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AwakeDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avataUrl => $composableBuilder(
    column: $table.avataUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepPastCount => $composableBuilder(
    column: $table.sleepPastCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lateCount => $composableBuilder(
    column: $table.lateCount,
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
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AwakeDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get avataUrl =>
      $composableBuilder(column: $table.avataUrl, builder: (column) => column);

  GeneratedColumn<int> get sleepPastCount => $composableBuilder(
    column: $table.sleepPastCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lateCount =>
      $composableBuilder(column: $table.lateCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> groupMembershipsRefs<T extends Object>(
    Expression<T> Function($$GroupMembershipsTableAnnotationComposer a) f,
  ) {
    final $$GroupMembershipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMemberships,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembershipsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMemberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventReportsRefs<T extends Object>(
    Expression<T> Function($$EventReportsTableAnnotationComposer a) f,
  ) {
    final $$EventReportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventReports,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventReportsTableAnnotationComposer(
            $db: $db,
            $table: $db.eventReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AwakeDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({
            bool groupMembershipsRefs,
            bool eventReportsRefs,
          })
        > {
  $$ProfilesTableTableManager(_$AwakeDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> avataUrl = const Value.absent(),
                Value<int> sleepPastCount = const Value.absent(),
                Value<int> lateCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                nickname: nickname,
                avataUrl: avataUrl,
                sleepPastCount: sleepPastCount,
                lateCount: lateCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nickname,
                required String avataUrl,
                Value<int> sleepPastCount = const Value.absent(),
                Value<int> lateCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                nickname: nickname,
                avataUrl: avataUrl,
                sleepPastCount: sleepPastCount,
                lateCount: lateCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({groupMembershipsRefs = false, eventReportsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupMembershipsRefs) db.groupMemberships,
                    if (eventReportsRefs) db.eventReports,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupMembershipsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          GroupMembership
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._groupMembershipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMembershipsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventReportsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          EventReport
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._eventReportsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).eventReportsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
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

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AwakeDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({bool groupMembershipsRefs, bool eventReportsRefs})
    >;
typedef $$GroupsTableCreateCompanionBuilder =
    GroupsCompanion Function({
      required String id,
      required String invitationCode,
      required String groupName,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$GroupsTableUpdateCompanionBuilder =
    GroupsCompanion Function({
      Value<String> id,
      Value<String> invitationCode,
      Value<String> groupName,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$GroupsTableReferences
    extends BaseReferences<_$AwakeDatabase, $GroupsTable, Group> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembershipsTable, List<GroupMembership>>
  _groupMembershipsRefsTable(_$AwakeDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groupMemberships,
        aliasName: $_aliasNameGenerator(
          db.groups.id,
          db.groupMemberships.groupId,
        ),
      );

  $$GroupMembershipsTableProcessedTableManager get groupMembershipsRefs {
    final manager = $$GroupMembershipsTableTableManager(
      $_db,
      $_db.groupMemberships,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupMembershipsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventsTable, List<Event>> _eventsRefsTable(
    _$AwakeDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.events,
    aliasName: $_aliasNameGenerator(db.groups.id, db.events.groupId),
  );

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupsTableFilterComposer
    extends Composer<_$AwakeDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
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

  ColumnFilters<String> get invitationCode => $composableBuilder(
    column: $table.invitationCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> groupMembershipsRefs(
    Expression<bool> Function($$GroupMembershipsTableFilterComposer f) f,
  ) {
    final $$GroupMembershipsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMemberships,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembershipsTableFilterComposer(
            $db: $db,
            $table: $db.groupMemberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventsRefs(
    Expression<bool> Function($$EventsTableFilterComposer f) f,
  ) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AwakeDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
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

  ColumnOrderings<String> get invitationCode => $composableBuilder(
    column: $table.invitationCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AwakeDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invitationCode => $composableBuilder(
    column: $table.invitationCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> groupMembershipsRefs<T extends Object>(
    Expression<T> Function($$GroupMembershipsTableAnnotationComposer a) f,
  ) {
    final $$GroupMembershipsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMemberships,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMembershipsTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMemberships,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventsRefs<T extends Object>(
    Expression<T> Function($$EventsTableAnnotationComposer a) f,
  ) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupsTableTableManager
    extends
        RootTableManager<
          _$AwakeDatabase,
          $GroupsTable,
          Group,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (Group, $$GroupsTableReferences),
          Group,
          PrefetchHooks Function({bool groupMembershipsRefs, bool eventsRefs})
        > {
  $$GroupsTableTableManager(_$AwakeDatabase db, $GroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invitationCode = const Value.absent(),
                Value<String> groupName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion(
                id: id,
                invitationCode: invitationCode,
                groupName: groupName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String invitationCode,
                required String groupName,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion.insert(
                id: id,
                invitationCode: invitationCode,
                groupName: groupName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GroupsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({groupMembershipsRefs = false, eventsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groupMembershipsRefs) db.groupMemberships,
                    if (eventsRefs) db.events,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groupMembershipsRefs)
                        await $_getPrefetchedData<
                          Group,
                          $GroupsTable,
                          GroupMembership
                        >(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._groupMembershipsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMembershipsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (eventsRefs)
                        await $_getPrefetchedData<Group, $GroupsTable, Event>(
                          currentTable: table,
                          referencedTable: $$GroupsTableReferences
                              ._eventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupsTableReferences(db, table, p0).eventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
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

typedef $$GroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AwakeDatabase,
      $GroupsTable,
      Group,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (Group, $$GroupsTableReferences),
      Group,
      PrefetchHooks Function({bool groupMembershipsRefs, bool eventsRefs})
    >;
typedef $$GroupMembershipsTableCreateCompanionBuilder =
    GroupMembershipsCompanion Function({
      required String id,
      required String groupId,
      required String userId,
      required int role,
      Value<DateTime> joinedAt,
      Value<int> rowid,
    });
typedef $$GroupMembershipsTableUpdateCompanionBuilder =
    GroupMembershipsCompanion Function({
      Value<String> id,
      Value<String> groupId,
      Value<String> userId,
      Value<int> role,
      Value<DateTime> joinedAt,
      Value<int> rowid,
    });

final class $$GroupMembershipsTableReferences
    extends
        BaseReferences<
          _$AwakeDatabase,
          $GroupMembershipsTable,
          GroupMembership
        > {
  $$GroupMembershipsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupsTable _groupIdTable(_$AwakeDatabase db) =>
      db.groups.createAlias(
        $_aliasNameGenerator(db.groupMemberships.groupId, db.groups.id),
      );

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProfilesTable _userIdTable(_$AwakeDatabase db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.groupMemberships.userId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroupMembershipsTableFilterComposer
    extends Composer<_$AwakeDatabase, $GroupMembershipsTable> {
  $$GroupMembershipsTableFilterComposer({
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

  ColumnFilters<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableFilterComposer get userId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembershipsTableOrderingComposer
    extends Composer<_$AwakeDatabase, $GroupMembershipsTable> {
  $$GroupMembershipsTableOrderingComposer({
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

  ColumnOrderings<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableOrderingComposer get userId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembershipsTableAnnotationComposer
    extends Composer<_$AwakeDatabase, $GroupMembershipsTable> {
  $$GroupMembershipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableAnnotationComposer get userId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroupMembershipsTableTableManager
    extends
        RootTableManager<
          _$AwakeDatabase,
          $GroupMembershipsTable,
          GroupMembership,
          $$GroupMembershipsTableFilterComposer,
          $$GroupMembershipsTableOrderingComposer,
          $$GroupMembershipsTableAnnotationComposer,
          $$GroupMembershipsTableCreateCompanionBuilder,
          $$GroupMembershipsTableUpdateCompanionBuilder,
          (GroupMembership, $$GroupMembershipsTableReferences),
          GroupMembership,
          PrefetchHooks Function({bool groupId, bool userId})
        > {
  $$GroupMembershipsTableTableManager(
    _$AwakeDatabase db,
    $GroupMembershipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMembershipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMembershipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMembershipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupMembershipsCompanion(
                id: id,
                groupId: groupId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String groupId,
                required String userId,
                required int role,
                Value<DateTime> joinedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupMembershipsCompanion.insert(
                id: id,
                groupId: groupId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroupMembershipsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false, userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable:
                                    $$GroupMembershipsTableReferences
                                        ._groupIdTable(db),
                                referencedColumn:
                                    $$GroupMembershipsTableReferences
                                        ._groupIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable:
                                    $$GroupMembershipsTableReferences
                                        ._userIdTable(db),
                                referencedColumn:
                                    $$GroupMembershipsTableReferences
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

typedef $$GroupMembershipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AwakeDatabase,
      $GroupMembershipsTable,
      GroupMembership,
      $$GroupMembershipsTableFilterComposer,
      $$GroupMembershipsTableOrderingComposer,
      $$GroupMembershipsTableAnnotationComposer,
      $$GroupMembershipsTableCreateCompanionBuilder,
      $$GroupMembershipsTableUpdateCompanionBuilder,
      (GroupMembership, $$GroupMembershipsTableReferences),
      GroupMembership,
      PrefetchHooks Function({bool groupId, bool userId})
    >;
typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      required String id,
      required String groupId,
      required String title,
      required String destinationName,
      required double latitude,
      required double longitude,
      required String qrcodeId,
      required String password,
      required DateTime arrivalTime,
      required int status,
      required DateTime eventDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<String> id,
      Value<String> groupId,
      Value<String> title,
      Value<String> destinationName,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> qrcodeId,
      Value<String> password,
      Value<DateTime> arrivalTime,
      Value<int> status,
      Value<DateTime> eventDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$EventsTableReferences
    extends BaseReferences<_$AwakeDatabase, $EventsTable, Event> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AwakeDatabase db) => db.groups
      .createAlias($_aliasNameGenerator(db.events.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupsTableTableManager(
      $_db,
      $_db.groups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EventReportsTable, List<EventReport>>
  _eventReportsRefsTable(_$AwakeDatabase db) => MultiTypedResultKey.fromTable(
    db.eventReports,
    aliasName: $_aliasNameGenerator(db.events.id, db.eventReports.eventId),
  );

  $$EventReportsTableProcessedTableManager get eventReportsRefs {
    final manager = $$EventReportsTableTableManager(
      $_db,
      $_db.eventReports,
    ).filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventReportsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AwakeDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
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

  ColumnFilters<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qrcodeId => $composableBuilder(
    column: $table.qrcodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableFilterComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> eventReportsRefs(
    Expression<bool> Function($$EventReportsTableFilterComposer f) f,
  ) {
    final $$EventReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventReports,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventReportsTableFilterComposer(
            $db: $db,
            $table: $db.eventReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AwakeDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
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

  ColumnOrderings<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qrcodeId => $composableBuilder(
    column: $table.qrcodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableOrderingComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AwakeDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
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

  GeneratedColumn<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get qrcodeId =>
      $composableBuilder(column: $table.qrcodeId, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<DateTime> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.groups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> eventReportsRefs<T extends Object>(
    Expression<T> Function($$EventReportsTableAnnotationComposer a) f,
  ) {
    final $$EventReportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventReports,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventReportsTableAnnotationComposer(
            $db: $db,
            $table: $db.eventReports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AwakeDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, $$EventsTableReferences),
          Event,
          PrefetchHooks Function({bool groupId, bool eventReportsRefs})
        > {
  $$EventsTableTableManager(_$AwakeDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> destinationName = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> qrcodeId = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<DateTime> arrivalTime = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime> eventDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                groupId: groupId,
                title: title,
                destinationName: destinationName,
                latitude: latitude,
                longitude: longitude,
                qrcodeId: qrcodeId,
                password: password,
                arrivalTime: arrivalTime,
                status: status,
                eventDate: eventDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String groupId,
                required String title,
                required String destinationName,
                required double latitude,
                required double longitude,
                required String qrcodeId,
                required String password,
                required DateTime arrivalTime,
                required int status,
                required DateTime eventDate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                groupId: groupId,
                title: title,
                destinationName: destinationName,
                latitude: latitude,
                longitude: longitude,
                qrcodeId: qrcodeId,
                password: password,
                arrivalTime: arrivalTime,
                status: status,
                eventDate: eventDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$EventsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false, eventReportsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (eventReportsRefs) db.eventReports],
              addJoins:
                  <
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
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable: $$EventsTableReferences
                                    ._groupIdTable(db),
                                referencedColumn: $$EventsTableReferences
                                    ._groupIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (eventReportsRefs)
                    await $_getPrefetchedData<Event, $EventsTable, EventReport>(
                      currentTable: table,
                      referencedTable: $$EventsTableReferences
                          ._eventReportsRefsTable(db),
                      managerFromTypedResult: (p0) => $$EventsTableReferences(
                        db,
                        table,
                        p0,
                      ).eventReportsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.eventId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AwakeDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, $$EventsTableReferences),
      Event,
      PrefetchHooks Function({bool groupId, bool eventReportsRefs})
    >;
typedef $$EventReportsTableCreateCompanionBuilder =
    EventReportsCompanion Function({
      required String id,
      required String eventId,
      required String userId,
      Value<DateTime?> plannedWakeupTime,
      Value<DateTime?> plannedDepartureTime,
      Value<DateTime?> actualWakeupTime,
      Value<DateTime?> actualDepartureTime,
      required int status,
      required String lateReason,
      required String photoUrl,
      required double latitude,
      required double longitude,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$EventReportsTableUpdateCompanionBuilder =
    EventReportsCompanion Function({
      Value<String> id,
      Value<String> eventId,
      Value<String> userId,
      Value<DateTime?> plannedWakeupTime,
      Value<DateTime?> plannedDepartureTime,
      Value<DateTime?> actualWakeupTime,
      Value<DateTime?> actualDepartureTime,
      Value<int> status,
      Value<String> lateReason,
      Value<String> photoUrl,
      Value<double> latitude,
      Value<double> longitude,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$EventReportsTableReferences
    extends BaseReferences<_$AwakeDatabase, $EventReportsTable, EventReport> {
  $$EventReportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$AwakeDatabase db) => db.events
      .createAlias($_aliasNameGenerator(db.eventReports.eventId, db.events.id));

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$EventsTableTableManager(
      $_db,
      $_db.events,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProfilesTable _userIdTable(_$AwakeDatabase db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.eventReports.userId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventReportsTableFilterComposer
    extends Composer<_$AwakeDatabase, $EventReportsTable> {
  $$EventReportsTableFilterComposer({
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

  ColumnFilters<DateTime> get plannedWakeupTime => $composableBuilder(
    column: $table.plannedWakeupTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get plannedDepartureTime => $composableBuilder(
    column: $table.plannedDepartureTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualWakeupTime => $composableBuilder(
    column: $table.actualWakeupTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualDepartureTime => $composableBuilder(
    column: $table.actualDepartureTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lateReason => $composableBuilder(
    column: $table.lateReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableFilterComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableFilterComposer get userId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventReportsTableOrderingComposer
    extends Composer<_$AwakeDatabase, $EventReportsTable> {
  $$EventReportsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get plannedWakeupTime => $composableBuilder(
    column: $table.plannedWakeupTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get plannedDepartureTime => $composableBuilder(
    column: $table.plannedDepartureTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualWakeupTime => $composableBuilder(
    column: $table.actualWakeupTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualDepartureTime => $composableBuilder(
    column: $table.actualDepartureTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lateReason => $composableBuilder(
    column: $table.lateReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableOrderingComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableOrderingComposer get userId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventReportsTableAnnotationComposer
    extends Composer<_$AwakeDatabase, $EventReportsTable> {
  $$EventReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get plannedWakeupTime => $composableBuilder(
    column: $table.plannedWakeupTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get plannedDepartureTime => $composableBuilder(
    column: $table.plannedDepartureTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get actualWakeupTime => $composableBuilder(
    column: $table.actualWakeupTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get actualDepartureTime => $composableBuilder(
    column: $table.actualDepartureTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lateReason => $composableBuilder(
    column: $table.lateReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.events,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventsTableAnnotationComposer(
            $db: $db,
            $table: $db.events,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableAnnotationComposer get userId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventReportsTableTableManager
    extends
        RootTableManager<
          _$AwakeDatabase,
          $EventReportsTable,
          EventReport,
          $$EventReportsTableFilterComposer,
          $$EventReportsTableOrderingComposer,
          $$EventReportsTableAnnotationComposer,
          $$EventReportsTableCreateCompanionBuilder,
          $$EventReportsTableUpdateCompanionBuilder,
          (EventReport, $$EventReportsTableReferences),
          EventReport,
          PrefetchHooks Function({bool eventId, bool userId})
        > {
  $$EventReportsTableTableManager(_$AwakeDatabase db, $EventReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime?> plannedWakeupTime = const Value.absent(),
                Value<DateTime?> plannedDepartureTime = const Value.absent(),
                Value<DateTime?> actualWakeupTime = const Value.absent(),
                Value<DateTime?> actualDepartureTime = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String> lateReason = const Value.absent(),
                Value<String> photoUrl = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventReportsCompanion(
                id: id,
                eventId: eventId,
                userId: userId,
                plannedWakeupTime: plannedWakeupTime,
                plannedDepartureTime: plannedDepartureTime,
                actualWakeupTime: actualWakeupTime,
                actualDepartureTime: actualDepartureTime,
                status: status,
                lateReason: lateReason,
                photoUrl: photoUrl,
                latitude: latitude,
                longitude: longitude,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String eventId,
                required String userId,
                Value<DateTime?> plannedWakeupTime = const Value.absent(),
                Value<DateTime?> plannedDepartureTime = const Value.absent(),
                Value<DateTime?> actualWakeupTime = const Value.absent(),
                Value<DateTime?> actualDepartureTime = const Value.absent(),
                required int status,
                required String lateReason,
                required String photoUrl,
                required double latitude,
                required double longitude,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventReportsCompanion.insert(
                id: id,
                eventId: eventId,
                userId: userId,
                plannedWakeupTime: plannedWakeupTime,
                plannedDepartureTime: plannedDepartureTime,
                actualWakeupTime: actualWakeupTime,
                actualDepartureTime: actualDepartureTime,
                status: status,
                lateReason: lateReason,
                photoUrl: photoUrl,
                latitude: latitude,
                longitude: longitude,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EventReportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eventId = false, userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (eventId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.eventId,
                                referencedTable: $$EventReportsTableReferences
                                    ._eventIdTable(db),
                                referencedColumn: $$EventReportsTableReferences
                                    ._eventIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$EventReportsTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$EventReportsTableReferences
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

typedef $$EventReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AwakeDatabase,
      $EventReportsTable,
      EventReport,
      $$EventReportsTableFilterComposer,
      $$EventReportsTableOrderingComposer,
      $$EventReportsTableAnnotationComposer,
      $$EventReportsTableCreateCompanionBuilder,
      $$EventReportsTableUpdateCompanionBuilder,
      (EventReport, $$EventReportsTableReferences),
      EventReport,
      PrefetchHooks Function({bool eventId, bool userId})
    >;

class $AwakeDatabaseManager {
  final _$AwakeDatabase _db;
  $AwakeDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$GroupMembershipsTableTableManager get groupMemberships =>
      $$GroupMembershipsTableTableManager(_db, _db.groupMemberships);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$EventReportsTableTableManager get eventReports =>
      $$EventReportsTableTableManager(_db, _db.eventReports);
}
