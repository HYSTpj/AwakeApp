import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'screen/createaccount_body.dart';
import 'package:flutter_application_1/data/profiles_repository.dart';
import '../grouplist_page.dart';

class CreateAccountProfile extends StatefulWidget {
  const CreateAccountProfile({super.key});

  @override
  State<CreateAccountProfile> createState() => _CreateAccountProfileState();
}

class _CreateAccountProfileState extends State<CreateAccountProfile> {
  final TextEditingController _userNameController = TextEditingController();
  dynamic _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // 処理中のぐるぐる表示用     
  final ProfilesRepository _profilesRepository = ProfilesRepository();                                                                                                                              

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


  // -- 画像選択の処理 --
  void _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        // Webの場合：バイトデータとして読み込む
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pickedImage = bytes; 
        });
      } else {
        // スマホの場合：従来通りFileとして扱う
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    }
  }

  // アカウント作成の処理(Firebaseへの保存など)
  void  _handleCreateAccount() async {
    final String name = _userNameController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (name.isEmpty) {
      _showSnackBar('ユーザー名を入力してください');
      return;
    }

    // ユーザーがログインしているか確認
    if (user == null) {
      _showSnackBar('ログインしていません');
      return;
    }

    try {
      // 画像があればFirebase StorageにアップロードしてURLを取得
      await _profilesRepository.setProfile(
        uid: user.uid,
        nickname: name,
        avatarUrl: '', // 画像URLは後で保存するので空でOK
      );

      print("保存に成功しました！");

      // 次の画面へ遷移
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GroupListPage()),
      );

    } catch (e) {
      _showSnackBar('プロファイルの保存に失敗しました: $e');
    }
  }

  void _returnToLogin() {
    Navigator.pop(context); // ログイン画面に戻る
  }

  //　ローディング状態の処理
  /*void _isLoading() {

  }*/
}