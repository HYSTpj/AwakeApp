import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class CreateAccountBody extends StatefulWidget {
  const CreateAccountBody({super.key});

  @override
  State<CreateAccountBody> createState() => _CreateAccountBodyState();
}

class _CreateAccountBodyState extends State<CreateAccountBody> {
  // --- 機能を管理する変数 ---
  final TextEditingController _userNameController = TextEditingController();
  dynamic _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // 処理中のぐるぐる表示用

  // --- 機能1：ギャラリーから画像を選ぶ ---
  Future<void> _pickImage() async {
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
  

  // --- 機能2：Firebaseへ保存するメイン処理 ---
  Future<void> _handleCreateAccount() async {
    final name = _userNameController.text.trim();
    
    if (name.isEmpty) {
      _showSnackBar('ユーザー名を入力してください');
      return;
    }

    setState(() => _isLoading = true); // ぐるぐる開始

    try {
      // Firebase Auth でログイン状態を確認（または匿名ログイン）
      // すでにログイン済みの場合は currentUser を使います
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        final credential = await FirebaseAuth.instance.signInAnonymously();
        user = credential.user;
      }
      final uid = user!.uid;

      String imageUrl = "";

      // 画像があれば Firebase Storage にアップロード
      if (_pickedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_icons')
            .child('$uid.jpg');
        
        if (kIsWeb) {
          // Webブラウザの場合：バイトデータとしてアップロード
          // _pickedImage が XFile型なら readAsBytes() でデータを取れます
          await storageRef.putData(_pickedImage!); 
        } else {
          // スマホ（iOS/Android）の場合：ファイルとしてアップロード
          await storageRef.putFile(File(_pickedImage!.path));
        }

        imageUrl = await storageRef.getDownloadURL();
      }

      // Firestore にプロフィール情報を書き込む
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'userName': name,
        'profileImageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('プロフィールを作成しました！');
      
      // 次の画面へ遷移
      // Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      _showSnackBar('エラーが発生しました: $e');
    } finally {
      setState(() => _isLoading = false); // ぐるぐる終了
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f6f6),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'CREATE PROFILE',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.8),
                  ),
                  const Text('Show the world who you are.', style: TextStyle(fontWeight: FontWeight.w700)),

                  const SizedBox(height: 40),

                  /* ユーザーネーム入力 */
                  const Text('USER NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  _buildTextField(),

                  const SizedBox(height: 30),

                  /* プロフィール画像表示 */
                  const Text('PROFILE PICTURE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  _buildImagePreview(),

                  const SizedBox(height: 15),

                  /* 画像アップロードボタン */
                  _neumorphicButton(
                    text: 'UPLOAD IMAGE',
                    color: Colors.white,
                    onPressed: _pickImage,
                  ),

                  const SizedBox(height: 40),

                  /* アカウント作成ボタン */
                  _neumorphicButton(
                    text: 'CREATE ACCOUNT',
                    color: const Color(0xFFEC5B13),
                    textColor: Colors.white,
                    height: 56,
                    onPressed: _handleCreateAccount,
                  ),

                  const SizedBox(height: 16),

                  /* 戻るボタン */
                  _neumorphicButton(
                    text: 'RETURN TO LOGIN',
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          // 処理中のオーバーレイ
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(color: Color(0xFFEC5B13))),
            ),
        ],
      ),
    );
  }

  // --- デザインパーツ ---

  Widget _buildTextField() {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: TextField(
        controller: _userNameController,
        decoration: const InputDecoration(
          hintText: 'Enter your username',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
        image: _pickedImage != null
            ? DecorationImage(
                image: kIsWeb 
                    ? MemoryImage(_pickedImage) as ImageProvider // Web用
                    : FileImage(_pickedImage), // スマホ用
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: _pickedImage == null
          ? const Icon(Icons.person, size: 64, color: Colors.grey)
          : null,
    );
  }

  Widget _neumorphicButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
    Color textColor = Colors.black,
    double height = 48,
  }) {
    return Container(
      width: 320,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w900)),
      ),
    );
  }
}