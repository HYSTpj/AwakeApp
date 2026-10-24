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

  /// 現在ログイン中のユーザーアカウントを完全に削除する
  Future<void> deleteAccount();
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

  /// 画像ファイルから Content-Type と拡張子を判定する共通ヘルパー
  (String contentType, String fileExt) _resolveImageFormat(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return ('image/png', 'png');
      case 'webp':
        return ('image/webp', 'webp');
      case 'gif':
        return ('image/gif', 'gif');
      case 'heic':
      case 'heif':
        return ('image/heic', 'heic');
      case 'jpg':
      case 'jpeg':
      default:
        return ('image/jpeg', 'jpg');
    }
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

    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('ユーザー名を入力してください');
    }
    if (trimmed.length > 30) {
      throw ArgumentError('ユーザー名は30文字以内で入力してください');
    }

    String? avatarUrl;
    String? uploadedFilePath;

    if (avatarImage != null) {
      final (contentType, fileExt) = _resolveImageFormat(avatarImage);
      uploadedFilePath =
          '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _client.storage
          .from('avatars')
          .upload(
            uploadedFilePath,
            avatarImage,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      avatarUrl = _client.storage
          .from('avatars')
          .getPublicUrl(uploadedFilePath);
    }

    final updateData = <String, dynamic>{
      'id': user.id,
      'nickname': trimmed,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (avatarUrl != null) {
      updateData['avatar_url'] = avatarUrl;
    }

    try {
      await _client.from('profiles').upsert(updateData);
    } catch (dbError, dbStackTrace) {
      developer.log(
        'DB更新失敗のためロールバックを実行します: $uploadedFilePath',
        name: 'AuthRepository',
        error: dbError,
        stackTrace: dbStackTrace,
      );

      if (uploadedFilePath != null) {
        try {
          await _client.storage.from('avatars').remove([uploadedFilePath]);
          developer.log(
            'ロールバック削除成功: $uploadedFilePath',
            name: 'AuthRepository',
          );
        } catch (storageError, storageStackTrace) {
          developer.log(
            'ロールバック削除中にエラーが発生しました',
            name: 'AuthRepository',
            error: storageError,
            stackTrace: storageStackTrace,
          );
        }
      }
      rethrow;
    }

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

    final (contentType, fileExt) = _resolveImageFormat(avatarImage);
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

    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> deleteAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('認証セッションがありません');
    }

    final userId = user.id;

    // 1. DB / Auth からのユーザー完全削除（RPC）
    // 理由を問わず RPC が失敗した場合は削除失敗として例外を投げる
    try {
      await _client.rpc('delete_user');
    } catch (e, st) {
      developer.log(
        'アカウント削除RPC呼び出しに失敗しました',
        name: 'AuthRepository',
        error: e,
        stackTrace: st,
      );
      throw const AuthException('アカウントの削除に失敗しました。時間をおいて再試行してください');
    }

    // 2. avatars の物理削除（ベストエフォート）
    try {
      await _deleteUserStorageFolder(bucket: 'avatars', folderPath: userId);
    } catch (e, st) {
      developer.log(
        'avatars の物理削除に失敗しました: $userId',
        name: 'AuthRepository',
        error: e,
        stackTrace: st,
      );
    }

    // 3. late-evidences の物理削除（ベストエフォート）
    try {
      await _deleteLateEvidenceFolder(userId: userId);
    } catch (e, st) {
      developer.log(
        'late-evidences の物理削除に失敗しました: $userId',
        name: 'AuthRepository',
        error: e,
        stackTrace: st,
      );
    }

    // 4. ローカルセッション破棄
    try {
      await _client.auth.signOut();
    } catch (e, st) {
      developer.log(
        'リモートアカウント削除後のローカルサインアウトで例外（警告扱い）',
        name: 'AuthRepository',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _deleteUserStorageFolder({
    required String bucket,
    required String folderPath,
  }) async {
    final allFilePaths = await _listAllFiles(bucket: bucket, path: folderPath);
    await _removeInChunks(bucket: bucket, paths: allFilePaths);
  }

  Future<void> _deleteLateEvidenceFolder({required String userId}) async {
    final eventDirs = await _listAllFiles(bucket: 'late-evidences', path: userId);
    final List<String> allFilePaths = [];

    for (final dirPath in eventDirs) {
      final files = await _listAllFiles(bucket: 'late-evidences', path: dirPath);
      allFilePaths.addAll(files);
    }

    await _removeInChunks(bucket: 'late-evidences', paths: allFilePaths);
  }

  Future<List<String>> _listAllFiles({
    required String bucket,
    required String path,
  }) async {
    final List<String> filePaths = [];
    const int pageSize = 100;
    int offset = 0;

    while (true) {
      final objects = await _client.storage.from(bucket).list(
            path: path,
            searchOptions: SearchOptions(
              limit: pageSize,
              offset: offset,
              sortBy: const SortBy(column: 'name', order: 'asc'),
            ),
          );

      if (objects.isEmpty) break;

      for (final obj in objects) {
        filePaths.add('$path/${obj.name}');
      }

      if (objects.length < pageSize) break;
      offset += pageSize;
    }

    return filePaths;
  }

  Future<void> _removeInChunks({
    required String bucket,
    required List<String> paths,
  }) async {
    if (paths.isEmpty) return;

    const int chunkSize = 100;
    for (int i = 0; i < paths.length; i += chunkSize) {
      final chunk = paths.sublist(
        i,
        i + chunkSize > paths.length ? paths.length : i + chunkSize,
      );
      await _client.storage.from(bucket).remove(chunk);
    }
  }
}