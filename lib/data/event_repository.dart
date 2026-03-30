// Firestoreからデータベースを取得するためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart';
import '../select_participants_page.dart';

// events ドキュメント
class EventRepository {
  EventRepository();
  final _db = FirebaseFirestore.instance;

  // イベント作成
  Future<String?> setEvent({
    required String groupId,
    required String title,
    required String destinationName,
    required String location,
    required String qrcodeId,
    required String password,
    required String arrivalTime,

    required String status
  }) async {
    final eventDoc = _db.collection('events').doc();
    final String eventId = eventDoc.id; // 自動生成されたドキュメントid

    // 2.イベント作成
    await eventDoc.set({
      'group_id': groupId,
      'title': title,
      'destination_name': destinationName,
      'location': location,
      'qrcode_id': qrcodeId,
      'password': password,
      'arrival_time': arrivalTime,
      'status': status,
      'created_at': FieldValue.serverTimestamp(), // Googleサーバーの正確な時間を取得
      'update_at': FieldValue.serverTimestamp()
    });

    return eventId;
  }
  // 3.イベント作成完了


  // 所属イベント一覧
  Future<List<Map<String, dynamic>>> getEvents(String groupId) async {
    final events = await _db // eventsから指定されたgroup_idと同じものの中身を調べる
      .collection("events")
      .where("group_id", isEqualTo: groupId)
      .get();

    return events.docs.map ((doc) {
      final data = doc.data();
      data['event_id'] = doc.id;  // ドキュメントIDをデータに含める
      return data;
    }).toList();
  }


  // イベント削除
  Future<void> deleteEvent({
    required String groupId,
    required String title
  }) async {
    final event = await _db
      .collection("events")
      .where("group_id", isEqualTo: groupId)
      .where("title", isEqualTo: title)
      .get();

    if (event.docs.isNotEmpty) {
      final docId = event.docs.first.id; // 上記で見つけた空出ないドキュメントidを指定
    
      await _db
        .collection("events")
        .doc(docId)
        .delete();
    }
  }

  // data/event_repository.dart 内に追加
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final snapshot = await _db
        .collection('users')
        .where('group_id', isEqualTo: groupId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> updateEventParticipants(String eventId, List<String> participants) async {
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .update({
      'participants': participants,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
