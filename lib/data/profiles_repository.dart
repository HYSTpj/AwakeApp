// Firestoreからデータベースを取得するためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart';

// profiles ドキュメント
class ProfilesRepository {
  final _db = FirebaseFirestore.instance;

  // プロフィール設定
  // 7.ユーザー名と画像URL保存
  Future<void> setProfile({
    required String uid,  // required => この引数は絶対にいるよという印
    required String nickname,
    required String avatarUrl,
  }) async {
    final profile = <String, dynamic>{  // 引数は文字だけでなくなんでもいいよという意味
      "nickname": nickname,
      "avatar_url": avatarUrl,
      "sleep_past_count": 0,
      "late_count": 0,
      "created_at": Timestamp.now(),
      "updated_at": Timestamp.now(),
    };
    await _db
      .collection("profiles")
      .doc(uid) // ユーザーごとにドキュメント追加
      .set(profile);
  }
  // 8.保存完了 (成功 => 戻り値void, 失敗 => error)

  // プロフィール更新
  Future<void> updateProfile({
    required String uid,
    required String nickname,
    required String avatarUrl,
  }) async {
    // 更新される項目だけ書く
    final upProfile = <String, dynamic>{
      "nickname": nickname,
      "avatar_url": avatarUrl,
      "updated_at": Timestamp.now(),
    };
    await _db
      .collection("profiles")
      .doc(uid)
      .update(upProfile);
  }

  // プロフィール表示
  Future<Map<String, dynamic>?> getProfile({required String uid}) async { // Map => キー付きのリスト{"nickname": "はな", "avatar_url": ...}
    final prof = await _db.collection("profiles").doc(uid).get();  // ドキュメントIDがuidの中身を調べる
    if (prof.exists) {
      return prof.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }
  /*
  {
    "nickname": "...",
    "avatar_url": "...",
    "sleep_past_count": ...,
    "late_count": ...,
    "created_at": ...,
    "updated_at": ...
  }
  というキーがあるリストが戻り値となるから，名前を取り出したい場合は
  `ProfilesRepository().getProfile(uid: "...")['nickname']`
  と書けば取り出せる
  */

  // 遅刻カウント
  Future<void> incrementSleep({required String uid}) async {
    final upSleep = <String, dynamic>{
      "sleep_past_count": FieldValue.increment(1),  // 1増加
      "updated_at": Timestamp.now(),
    };
    await _db
      .collection("profiles")
      .doc(uid)
      .update(upSleep);
  }

  // 寝坊カウント
  Future<void> incrementLate({required String uid}) async {
    final upLate = <String, dynamic>{
      "late_count": FieldValue.increment(1),  // 1増加
      "updated_at": Timestamp.now(),
    };
    await _db
      .collection("profiles")
      .doc(uid)
      .update(upLate);
  }
}
