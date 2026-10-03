import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile.dart';

// サインアップ後、メール確認が完了するまでセッションが発行されない状態を示す例外
// （メール/パスワード不正などの通常の失敗とは区別して扱うためのマーカー）
class EmailConfirmationPendingException implements Exception {
  const EmailConfirmationPendingException();
}

// 認証および認証ユーザープロフィールのデータ操作を抽象化するインターフェース
abstract class AuthRepository {
  // メールアドレスとパスワードを用いて新規アカウントを登録する
  Future<Profile> signUp({
    required String email,
    required String password,
  });

  // メールアドレスとパスワードでサインインする
  Future<Profile> signIn({
    required String email,
    required String password,
  });

  // 現在のセッションからサインアウトする
  Future<void> signOut();

  // 現在ログイン中のユーザーのプロフィール情報を取得する（未ログイン時は null）
  Future<Profile?> getCurrentProfile();

  // 現在ログイン中のユーザーID（UUID）を取得する（未ログイン時は null）
  String? get currentUserId;

  // パスワード再設定メールを送信する
  Future<void> resetPassword({required String email});

  // ニックネーム・プロフィール画像を更新する（画像が無ければニックネームのみ更新）
  Future<Profile> updateProfile({
    required String nickname,
    File? avatarImage,
  });
}

// Supabase Auth および PostgreSQL（profilesテーブル）を用いた認証リポジトリ実装
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Future<Profile> signUp({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signUp(email: email, password: password);

    final user = res.user;
    if (user == null) {
      throw const AuthException('User creation failed');
    }

    if (res.session == null) {
      // メール確認待ち（通常の失敗ではない）であることを専用の例外で伝える
      throw const EmailConfirmationPendingException();
    }

    return _fetchProfileWithRetry(user.id);
  }

  @override
  Future<Profile> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;
    if (user == null) {
      throw const AuthException('Invalid login credentials');
    }

    final profile = await getCurrentProfile();
    if (profile == null) {
      throw const AuthException('Profile not found');
    }
    return profile;
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<Profile?> getCurrentProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;

    // RLS により認証ユーザー自身の行のみ取得可能
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (data == null) return null;
    return Profile.fromJson(data);
  }

  // サインアップ直後は DB トリガー（handle_new_user）の実行完了までに
  // わずかな非同期遅延が発生する場合があるため、一定回数ポーリングしてプロフィールを取得する
  Future<Profile> _fetchProfileWithRetry(
    String userId, {
    int retries = 3,
  }) async {
    for (int i = 0; i < retries; i++) {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        return Profile.fromJson(data);
      }

      // 次のリトライまで待機（300ms）
      await Future.delayed(const Duration(milliseconds: 300));
    }

    throw const AuthException('Timed out waiting for profile creation trigger');
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<Profile> updateProfile({
    required String nickname,
    File? avatarImage,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('ログインしていません');
    }

    String? avatarUrl;
    if (avatarImage != null) {
      final filePath =
          '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _client.storage.from('avatars').upload(
            filePath,
            avatarImage,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      avatarUrl = _client.storage.from('avatars').getPublicUrl(filePath);
    }

    final updateData = <String, dynamic>{
      'id': user.id,
      'nickname': nickname,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (avatarUrl != null) {
      updateData['avatar_url'] = avatarUrl;
    }

    await _client.from('profiles').upsert(updateData);

    final profile = await getCurrentProfile();
    if (profile == null) {
      throw const AuthException('Profile not found');
    }
    return profile;
  }
}
