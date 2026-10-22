import 'dart:io';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile.dart';

// サインアップ後、メール確認が完了するまでセッションが発行されない状態を示す例外
class EmailConfirmationPendingException implements Exception {
  const EmailConfirmationPendingException();
}

// 認証および認証ユーザープロフィールのデータ操作を抽象化するインターフェース
abstract class AuthRepository {
  // メールアドレスとパスワードを用いて新規アカウントを登録する
  Future<Profile> signUp({required String email, required String password});

  // メールアドレスとパスワードでサインインする
  Future<Profile> signIn({required String email, required String password});

  // 現在のセッションからサインアウトする
  Future<void> signOut();

  // 現在ログイン中のユーザーのプロフィール情報を取得する（未ログイン時は null）
  Future<Profile?> getCurrentProfile();

  // 現在ログイン中のユーザーID（UUID）を取得する（未ログイン時は null）
  String? get currentUserId;

  // パスワード再設定メールを送信する
  Future<void> resetPassword({required String email});

  // ニックネーム・プロフィール画像を更新する（画像が無ければニックネームのみ更新）
  Future<Profile> updateProfile({required String nickname, File? avatarImage});

  // ユーザー名（ニックネーム）単体を更新する
  Future<Profile> updateNickname(String newNickname);

  /// プロフィール画像のみを更新する
  Future<Profile> updateAvatar(File avatarImage);

  /// パスワードを変更・更新する（現在のパスワードで再認証を行う）
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
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

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (data == null) return null;
    return Profile.fromJson(data);
  }

  // サインアップ直後の DB トリガー完了待ちポーリング
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

    // updateProfile 側も 30 文字ガードとトリムを適用して統一
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('ユーザー名を入力してください');
    }
    if (trimmed.length > 30) {
      throw ArgumentError('ユーザー名は30文字以内で入力してください');
    }

    String? avatarUrl;
    if (avatarImage != null) {
      final filePath =
          '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _client.storage
          .from('avatars')
          .upload(
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
      'nickname': trimmed,
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

  @override
  Future<Profile> updateNickname(String newNickname) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('ユーザーが認証されていません');
    }

    // 入力値をトリムし、空欄と文字数を検証
    final trimmed = newNickname.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('ユーザー名を入力してください');
    }
    if (trimmed.length > 30) {
      throw ArgumentError('ユーザー名は30文字以内で入力してください');
    }

    final response = await _client
        .from('profiles')
        .update({
          'nickname': trimmed,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', userId)
        .select()
        .single();

    return Profile.fromJson(response);
  }

  @override
  Future<Profile> updateAvatar(File avatarImage) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('ログインしていません');
    }

    final currentProfileRes = await _client
        .from('profiles')
        .select('avatar_url')
        .eq('id', user.id)
        .maybeSingle();
    final oldAvatarUrl = currentProfileRes?['avatar_url'] as String?;

    final extension = avatarImage.path.split('.').last.toLowerCase();
    final String contentType;
    final String fileExt;

    switch (extension) {
      case 'png':
        contentType = 'image/png';
        fileExt = 'png';
        break;
      case 'webp':
        contentType = 'image/webp';
        fileExt = 'webp';
        break;
      case 'gif':
        contentType = 'image/gif';
        fileExt = 'gif';
        break;
      case 'heic':
      case 'heif':
        contentType = 'image/heic';
        fileExt = 'heic';
        break;
      case 'jpg':
      case 'jpeg':
      default:
        contentType = 'image/jpeg';
        fileExt = 'jpg';
        break;
    }

    final newFilePath =
        '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await _client.storage
        .from('avatars')
        .upload(
          newFilePath,
          avatarImage,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );

    final newAvatarUrl = _client.storage
        .from('avatars')
        .getPublicUrl(newFilePath);

    final Map<String, dynamic> response;
    try {
      response = await _client
          .from('profiles')
          .update({
            'avatar_url': newAvatarUrl,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id)
          .select()
          .single();
    } catch (dbError, dbStackTrace) {
      developer.log(
        'DB更新失敗のためロールバックを実行します: $newFilePath',
        name: 'AuthRepository',
        error: dbError,
        stackTrace: dbStackTrace,
      );

      try {
        await _client.storage.from('avatars').remove([newFilePath]);
        developer.log('ロールバック削除成功: $newFilePath', name: 'AuthRepository');
      } catch (storageError, storageStackTrace) {
        developer.log(
          'ロールバック削除中にエラーが発生しました',
          name: 'AuthRepository',
          error: storageError,
          stackTrace: storageStackTrace,
        );
      }

      rethrow;
    }

    if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
      await _deleteOldAvatarQuietly(user.id, oldAvatarUrl);
    }

    return Profile.fromJson(response);
  }

  /// 古いアバター画像を安全に削除
  Future<void> _deleteOldAvatarQuietly(String userId, String oldUrl) async {
    try {
      final uri = Uri.tryParse(oldUrl);
      if (uri == null) return;

      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf('avatars');
      if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
        final oldPath = segments.sublist(bucketIndex + 1).join('/');
        if (oldPath.startsWith('$userId/')) {
          await _client.storage.from('avatars').remove([oldPath]);
          developer.log('古いアバター画像を削除しました: $oldPath', name: 'AuthRepository');
        }
      }
    } catch (e, st) {
      developer.log(
        '古いアバター画像の削除に失敗しました',
        name: 'AuthRepository',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.isEmpty) {
      throw ArgumentError('現在のパスワードを入力してください');
    }
    if (newPassword.isEmpty) {
      throw ArgumentError('新しいパスワードを入力してください');
    }
    if (newPassword.length < 6) {
      throw ArgumentError('パスワードは6文字以上で入力してください');
    }
    if (newPassword == currentPassword) {
      throw ArgumentError('新しいパスワードは現在のパスワードと異なるものを設定してください');
    }

    final user = _client.auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw const AuthException('認証セッションがありません');
    }

    // 1. 現在のパスワードで再認証を試みる
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
    } on AuthException catch (e) {
      if (e.message == 'Invalid login credentials') {
        throw const AuthException('現在のパスワードが正しくありません');
      }
      rethrow;
    }

    // 2. 新しいパスワードに更新する
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}
