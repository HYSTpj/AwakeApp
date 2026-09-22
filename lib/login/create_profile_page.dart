import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screen/create_account_body.dart';
import '../group/view/group_list_view.dart';

class CreateAccountProfile extends StatefulWidget {
  const CreateAccountProfile({super.key});

  @override
  State<CreateAccountProfile> createState() => _CreateAccountProfileState();
}

class _CreateAccountProfileState extends State<CreateAccountProfile> {
  final TextEditingController _userNameController = TextEditingController();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // CreateAccountBodyを呼び出す
    return createAccountBody(
      context,
      onUploadImagePressed: _pickImage,
      onCreateAccountPressed: _handleCreateAccount,
      onReturnToLoginPressed: _returnToLogin,
      userNameController: _userNameController,
      pickedImage: _pickedImage,
      isLoading: _isLoading,
    );
  }

  // スナックバー表示の処理
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // 画像選択の処理
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  // アカウント作成の処理(Supabaseへの保存など)
  Future<void> _handleCreateAccount() async {
    final String name = _userNameController.text.trim();
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (name.isEmpty) {
      _showSnackBar('ユーザー名を入力してください');
      return;
    }

    // ユーザーがログインしているか確認
    if (user == null) {
      _showSnackBar('ログインしていません');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 画像があればSupabase StorageにアップロードしてURLを取得
      String? avatarUrl;
      if (_pickedImage != null) {
        final filePath = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await client.storage.from('avatars').upload(
          filePath,
          _pickedImage!,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

        avatarUrl = client.storage.from('avatars').getPublicUrl(filePath);
      }

      // profiles テーブルの更新 (upsert)
      final updateData = <String, dynamic>{
        'id': user.id,
        'nickname': name,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      await client.from('profiles').upsert(updateData);

      debugPrint("プロフィール保存に成功しました");
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GroupListPage()),
      );
    } catch (e) {
      debugPrint("プロファイル保存エラー: $e");
      if (!mounted) return;
      _showSnackBar('プロファイルの保存に失敗しました: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _returnToLogin() {
    Navigator.pop(context); // ログイン画面に戻る
  }
}