import 'package:drift/drift.dart';
import '../../database/database.dart';

class RoomRepository{
  final AwakeDatabase db;
  RoomRepository(this.db);

  Stream<List<Group>> watchRooms(){
    return db.watchAllGroups();
  }

  Future<void> saveRoomToLocal(Group group) {
    return db.upsertGroup(
      GroupsCompanion.insert(
        id: group.id,
        groupName: group.groupName,
        invitationCode: group.invitationCode,
        createdAt: Value(group.createdAt),
      ),
    );
  }

  Future<void> syncFromFirebase(String id, Map<String, dynamic> data) async {
    final groupName = data['group_name'] ?? data['groupName'];
    final invitationCode = data['invitation_code'] ?? data['invitationCode'];

    await db.into(db.groups).insertOnConflictUpdate(
      GroupsCompanion.insert(
        id: id,
        groupName: groupName,
        invitationCode: invitationCode,
        createdAt: Value(createdAtTime),
      ),
    );
  }
}
