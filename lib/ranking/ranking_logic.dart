/* 
  * ranking_logic.dart
  * 
  * 遅刻回数をランキング化して表示するロジック 
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// メンバー一人分のランキング用データを入れる箱
class RankingUser {

  RankingUser({
    required this.uid, // ユーザーID
    required this.nickname, // ユーザー名
    required this.avatarUrl, // ユーザーのアイコンURL
    required this.lateCount, // 遅刻回数
    required this.sleepcount, // 寝過ごし回数
  });

  final String uid;
  final String nickname;
  final String avatarUrl;
  final int lateCount;
  final int sleepcount;
}

// グループの遅刻回数を計算してランキング順に並べる
class RankingLogic {
  final _db = FirebaseFirestore.instance; // データーベースにアクセスするためのインスタンス

  //　グループに所属するメンバーのランキングデータを取得する関数
  Future<List<RankingUser>> getGroupRanking(String groupId) async {
    try {
      // profiles コレクションから、指定された「groupId」に入っている人を全員探す
      final querySnapshot = await _db
          .collection("profiles")
          .where("group_id", isEqualTo: groupId) // グループIDで絞り込み
          .get();

      // データをRankingUserのリストに変換する
      List<RankingUser> users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        
        return RankingUser(
          uid: doc.id,
          nickname: data['nickname'] ?? '名前なし',
          avatarUrl: data['avatar_url'] ?? '',
          lateCount: data['late_count'] ?? 0,
          sleepcount: data['sleep_past_count'] ?? 0,
        );
      }).toList();

      //【重要】遅刻回数（lateCount）が多い順に並び替える（ソート）
      users.sort((a, b) => b.lateCount.compareTo(a.lateCount));

      return users;
      
    } catch (e) {
      debugPrint("ランキングの取得に失敗しました: $e");
      return []; // エラーが起きたら空っぽのリストを返す
    }
  }
}