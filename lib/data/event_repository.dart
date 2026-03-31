import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';

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
    required String status,
  }) async {
    final eventDoc = _db.collection('events').doc();
    final String eventId = eventDoc.id; // 自動生成されたドキュメントid

    // パスワードのハッシュ化（ソルト生成とSHA-256計算）
    final salt = _generateSalt();
    final hashedPassword = _hashPassword(password, salt);

    // 2.イベント作成
    await eventDoc.set({
      'group_id': groupId,
      'title': title,
      'destination_name': destinationName,
      'location': location,
      'qrcode_id': qrcodeId,
      'password_hash': hashedPassword, // ハッシュ化されたパスワードを保存
      'password_salt': salt,           // 生成したソルトも一緒に保存
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
    await _db
        .collection("events")
        .doc(eventId).delete();
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

  // グループに所属するメンバー一覧を取得
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final snapshot = await _db
        .collection('users')
        .where('group_id', isEqualTo: groupId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id; // ドキュメントIDをuidとして利用
      return data;
    }).toList();
  }

  Future<void> updateEventParticipants(String eventId, List<String> participants) async {
    await _db
        .collection('events')
        .doc(eventId)
        .update({
      'participants': participants,
      'update_at': FieldValue.serverTimestamp(),
    });
  }

  // --- event_reports 関連 ---

  // 予定時間（起床・出発）を保存または更新する
  Future<String?> setReport({
    required String eventId,
    required String userId,
    required DateTime wakeupTime,
    required DateTime departureTime,
  }) async {
    // すでにそのイベントのレポートが存在するか確認
    final existingReport = await getEventReport(eventId, userId);

    if (existingReport != null) {
      // 存在する場合は「更新(update)」
      final String reportId = existingReport['report_id'];
      await _db.collection("event_reports").doc(reportId).update({
        "planned_wakeup_time": wakeupTime,
        "planned_departure_time": departureTime,
        "updated_at": FieldValue.serverTimestamp(),
      });
      return reportId;
    } else {
      // 存在しない場合は「新規作成(add)」
      final docRef = await _db.collection("event_reports").add({
        "event_id": eventId,
        "user_id": userId,
        "planned_wakeup_time": wakeupTime,
        "planned_departure_time": departureTime,
        "status": 0, // 0: sleeping (初期状態)
        "created_at": FieldValue.serverTimestamp(),
        "updated_at": FieldValue.serverTimestamp(),
      });
      return docRef.id;
    }
  }

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

  // レポートが存在しない場合に空のレポートを作成する
  Future<String> createReportIfNotExist(String eventId, String userId) async {
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
      if (data != null) {
        // 新しい仕様: ハッシュ化パスワードの照合
        if (data.containsKey('password_hash') && data.containsKey('password_salt')) {
          final savedHash = data['password_hash'] as String;
          final savedSalt = data['password_salt'] as String;
          final inputHash = _hashPassword(inputPassword, savedSalt);
          
          if (inputHash == savedHash) {
            return true;
          }
        } else {
          // 古い仕様 (後方互換性): 以前の平文テストデータのためのフォールバック
          if (data['password'] == inputPassword) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // ==== プライベートヘルパーメソッド ====

  // パスワードのハッシュ化（SHA-256）
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ランダムなソルトの生成
  String _generateSalt([int length = 16]) {
    final rand = math.Random.secure();
    final saltBytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64UrlEncode(saltBytes);
  }
}
