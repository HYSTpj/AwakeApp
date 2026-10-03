import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'screen/create_account_body.dart';
import '../../viewmodels/auth_view_model.dart';
import '../group/group_list_view.dart';

class CreateAccountProfile extends StatefulWidget {
  const CreateAccountProfile({super.key});

  @override
  State<CreateAccountProfile> createState() => _CreateAccountProfileState();
}

class _CreateAccountProfileState extends State<CreateAccountProfile> {
  final TextEditingController _userNameController = TextEditingController();
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // isLoading の変化で再描画されるよう state を購読する
    final isLoading = context.watch<AuthViewModel>().state.isLoading;

    // CreateAccountBodyを呼び出す
    return createAccountBody(
      context,
      onUploadImagePressed: _pickImage,
      onCreateAccountPressed: _handleCreateAccount,
      onReturnToLoginPressed: _returnToLogin,
      userNameController: _userNameController,
      pickedImage: _pickedImage,
      isLoading: isLoading,
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

  // アカウント作成の処理(AuthViewModel経由でプロフィールを保存)
  Future<void> _handleCreateAccount() async {
    final authViewModel = context.read<AuthViewModel>();
    // 再描画が間に合わず連打で呼ばれた場合、誤った失敗メッセージを出さず黙って無視する
    if (authViewModel.state.isLoading) return;

    final String name = _userNameController.text.trim();
    if (name.isEmpty) {
      _showSnackBar('ユーザー名を入力してください');
      return;
    }

    final success = await authViewModel.completeProfile(
      nickname: name,
      avatarImage: _pickedImage,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GroupListPage()),
      );
    } else {
      final errorMsg = authViewModel.state.errorMessage ?? 'プロフィールの保存に失敗しました';
      _showSnackBar(errorMsg);
    }
  }

  void _returnToLogin() {
    Navigator.pop(context); // ログイン画面に戻る
  }
}
