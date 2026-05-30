// Firestoreからデータベースを取得するためのパッケージ
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

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
      "created_at": FieldValue.serverTimestamp(),
      "updated_at": FieldValue.serverTimestamp(),
    };
    await _db
      .collection("profiles")
      .doc(uid) // ユーザーごとにドキュメント追加
      .set(profile);
  }
  // 8.保存完了 (成功 => 戻り値void, 失敗 => error)

  // アイコン画像のアップロード
  Future<String?> uploadProfileImage({
    required String uid,
    required dynamic image, // File または Uint8List が渡される
  }) async {
    try {
      // Firebase Storageの保存先パスを作成（例: profiles/ユーザーID.jpg）
      final storageRef = FirebaseStorage.instance.ref().child('profiles/$uid.jpg');
      
      // 画像データ（File または Web用のUint8List）をアップロード
      if (image is File) {
        await storageRef.putFile(image);
      } else if (image is Uint8List) {
        await storageRef.putData(image);
      } else {
        return null; // サポートされていない形式の場合は何もしない
      }
      
      // アップロードした画像のURLを取得して返す
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('画像アップロードエラー: $e');
      return null;
    }
  }

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
