import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
part 'database.g.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get nickname => text()();
  TextColumn get avataUrl => text()();
  IntColumn get sleepPastCount => integer().withDefault(const Constant(0))();
  IntColumn get lateCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get invitationCode => text()();
  TextColumn get groupName => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class GroupMemberships extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id)();
  TextColumn get userId => text().references(Profiles, #id)();
  IntColumn get role => integer()();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Events extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id)();
  TextColumn get title => text()();
  TextColumn get destinationName => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get qrcodeId => text()();
  TextColumn get password => text()();
  DateTimeColumn get arrivalTime => dateTime()();
  IntColumn get status => integer()();
  DateTimeColumn get eventDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class EventReports extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();
  TextColumn get userId => text().references(Profiles, #id)();
  DateTimeColumn get plannedWakeupTime => dateTime().nullable()();
  DateTimeColumn get plannedDepartureTime => dateTime().nullable()();
  DateTimeColumn get actualWakeupTime => dateTime().nullable()();
  DateTimeColumn get actualDepartureTime => dateTime().nullable()();
  IntColumn get status => integer()();
  TextColumn get lateReason => text()();
  TextColumn get photoUrl => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Profiles,
  Groups,
  GroupMemberships,
  Events,
  EventReports,
])
class AwakeDatabase extends _$AwakeDatabase {
  AwakeDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      beforeOpen: (details) async {
        // SQLiteの外部キー制約をデフォルトで有効化する（Driftベストプラクティス）
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );

  Future<void> upsertGroup(GroupsCompanion entity) {
    return into(groups).insertOnConflictUpdate(entity);
  }
  Stream<List<Group>> watchAllGroups() => select(groups).watch();
}