// Firestoreからデータベースを取得するためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart';

// events ドキュメント
class EventRepository {
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

  // --- event_reports 関連 ---

  // レポートの取得
  Future<Map<String, dynamic>?> getEventReport(String eventId, String userId) async {
    final report = await _db
      .collection("event_reports")
      .where("event_id", isEqualTo: eventId)
      .where("user_id", isEqualTo: userId)
      .get();
    
    if (report.docs.isNotEmpty) {
      final data = report.docs.first.data();
      data['report_id'] = report.docs.first.id;
      return data;
    }
    return null;
  }

  // テスト用：レポートが存在しない場合に空のレポートを作成する
  Future<String> createDummyReportIfNotExist(String eventId, String userId) async {
    final report = await getEventReport(eventId, userId);
    if (report != null) return report['report_id'];

    final docRef = await _db.collection("event_reports").add({
      "event_id": eventId,
      "user_id": userId,
      "status": 0, // sleeping
      "created_at": FieldValue.serverTimestamp(),
      "updated_at": FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // 起床時間の更新
  Future<void> updateWakeupTime(String reportId) async {
    await _db.collection("event_reports").doc(reportId).update({
      "actual_wakeup_time": FieldValue.serverTimestamp(),
      "status": 1, // awake
      "updated_at": FieldValue.serverTimestamp(),
    });
  }

  // 出発時間の更新
  Future<void> updateDepartureTime(String reportId) async {
    await _db.collection("event_reports").doc(reportId).update({
      "actual_departure_time": FieldValue.serverTimestamp(),
      "status": 3, // moving
      "updated_at": FieldValue.serverTimestamp(),
    });
  }

  // チェックイン(到着)ステータスの更新
  Future<void> updateCheckInStatus(String reportId) async {
    await _db.collection("event_reports").doc(reportId).update({
      "status": 4, // arrived
      "updated_at": FieldValue.serverTimestamp(),
    });
  }

  // 寝坊ステータスの更新
  Future<void> updateOversleptStatus(String reportId) async {
    await _db.collection("event_reports").doc(reportId).update({
      "status": 2, // overslept
      "updated_at": FieldValue.serverTimestamp(),
    });
  }

  // QRコード検証: 読み取った値が該当イベントのqrcode_idと一致するか確認
  Future<bool> verifyEventQRCode(String eventId, String scannedQr) async {
    final eventDoc = await _db.collection('events').doc(eventId).get();
    if (eventDoc.exists) {
      final data = eventDoc.data();
      if (data != null && data['qrcode_id'] == scannedQr) {
        return true;
      }
    }
    return false;
  }

  // 手動パスワード検証: 読み取った値が該当イベントのpasswordと一致するか確認
  Future<bool> verifyEventPassword(String eventId, String inputPassword) async {
    final eventDoc = await _db.collection('events').doc(eventId).get();
    if (eventDoc.exists) {
      final data = eventDoc.data();
      if (data != null && data['password'] == inputPassword) {
        return true;
      }
    }
    return false;
  }
}
