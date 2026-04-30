import 'dart:ffi';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'database.g.dart';

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
  AwakeDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}