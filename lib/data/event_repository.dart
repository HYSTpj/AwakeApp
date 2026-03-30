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
    required String status,
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
      'update_at': FieldValue.serverTimestamp(),
    });

    return eventId;
  }
  // 3.イベント作成完了

  // 所属イベント一覧
  Future<List<Map<String, dynamic>>> getEvents(String groupId) async {
    final events =
        await _db // eventsから指定されたgroup_idと同じものの中身を調べる
            .collection("events")
            .where("group_id", isEqualTo: groupId)
            .get();

    return events.docs.map((doc) {
      final data = doc.data();
      data['event_id'] = doc.id; // ドキュメントIDをデータに含める
      return data;
    }).toList();
  }

  // イベント削除
  Future<void> deleteEvent({
    required String eventId // 同じイベント名でも削除されないように
  }) async {
    final event = await _db
        .collection("events")
        .doc(eventId).delete();
    }
  }

  // メンバーリストの取得
  Future<List<Map<String, dynamic>>> getEventMembers(String eventId) async {
    final eventMembersSnapshot =
        await _db // event_reportsから指定されたeventIdと同じものの中身を調べる
            .collection("event_reports")
            .where("event_id", isEqualTo: eventId)
            .get();

    final profileFutures = eventMembersSnapshot.docs.map((doc) async {
      // 全員分のprofile取得を予約リストにする
      final reportData = doc.data();
      final userId = reportData['user_id'];
      final userDoc = await _db
          .collection('profiles')
          .doc(userId)
          .get(); // 一人一人のprofile取得を予約
      if (userDoc.exists) {
        final profileData = userDoc.data()!;
        profileData['user_id'] = userId;
        profileData['status'] = reportData['status'];
        profileData['report_id'] = doc.id;
        return profileData;
      }
      return null;
    }).toList();
    final results = await Future.wait(profileFutures); // 全員分終わるまで待つ
    return results
        .whereType<Map<String, dynamic>>()
        .toList(); // nullの人は除去してリスト化
  }

  // 遅刻者理由，写真取得
  Future<Map<String, dynamic>?> getMemberReport(
    String eventId,
    String userId,
  ) async {
    final snapshot =
        await _db // event_reports内のevent_idとuser_idが一致するものの中身を調べる
            .collection("event_reports")
            .where("event_id", isEqualTo: eventId)
            .where("user_id", isEqualTo: userId)
            .orderBy("updated_at", descending: true) // 更新日時順
            //データベース見る限りcreated_atないけど新しく作る？or updated_atで並べ替えするか
            .limit(1) // 1件だけ
            .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data(); // 一番新しいレポートを1件返す
    }
    return null;
  }
}
