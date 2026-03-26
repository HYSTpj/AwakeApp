// Firestoreからデータベースを取得するためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart';

// events ドキュメント
class EventRepository {
  final _db = FirebaseFirestore.instance;

  // イベント作成
  Future<String?> setEvent({
    required String group_id,
    required String title,
    required String destination_name,
    required String location,
    required String qrcode_id,
    required String password,
    required String arrival_time,
    required String status
  }) async {
    final eventDoc = _db.collection('events').doc();
    final String eventId = eventDoc.id; // 自動生成されたドキュメントid

    // 2.イベント作成
    await eventDoc.set({
      'group_id': group_id,
      'title': title,
      'destination_name': destination_name,
      'location': location,
      'qrcode_id': qrcode_id,
      'password': password,
      'arrival_time': arrival_time,
      'status': status,
      'created_at': FieldValue.serverTimestamp(), // Googleサーバーの正確な時間を取得
      'update_at': FieldValue.serverTimestamp()
    });

    return eventId;
  }
  // 3.イベント作成完了


  // 所属イベント一覧
  Future<List<Map<String, dynamic>>> getEvents(String group_id) async {
    final events = await _db // eventsから指定されたgroup_idと同じものの中身を調べる
      .collection("events")
      .where("group_id", isEqualTo: group_id)
      .get();

    return events.docs.map((doc) => doc.data()).toList(); // イベントドキュメントをリスト化する
  }


  // イベント削除
  Future<void> deleteEvent({
    required String group_id,
    required String title
  }) async {
    final event = await _db
      .collection("events")
      .where("group_id", isEqualTo: group_id)
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
}
