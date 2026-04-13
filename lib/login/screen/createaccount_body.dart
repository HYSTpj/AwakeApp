/*
* これはcreateprofile画面のUIコードです．
*/

import 'package:flutter/material.dart';
import 'login_header_screen.dart'; 
import '../../grouplist_page.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

Widget createAccountBody(
  BuildContext context,
  {required VoidCallback onUploadImagePressed,
   required VoidCallback onCreateAccountPressed,
   required VoidCallback onReturnToLoginPressed,
   required TextEditingController userNameController,
   required dynamic pickedImage,
   required bool isLoading,}
  ) {
  return Scaffold(
    backgroundColor: const Color(0xFFf8f6f6),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            myHeader(),  // ロゴとタイトルのヘッダー

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'CREATE PROFILE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 32, 
                      fontFamily: 'Noto Sans JP',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Show the world who you are. Customize your look.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('USER NAME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))
                  ),
                  
                  const SizedBox(height: 8),

                  // ユーザーネーム入力欄
                  Container(
                    width: double.infinity, // 💡 固定320から画面幅いっぱいに変更
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF6B7280)),
                    ),
                    child: TextField(
                      controller: userNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your username',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('PROFILE PICTURE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))
                  ),

                  const SizedBox(height: 16),

                  // プロフィール画像（丸）
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                      image: pickedImage != null
                          ? DecorationImage(
                              image: kIsWeb
                                  ? MemoryImage(pickedImage as Uint8List)
                                  : FileImage(pickedImage as File),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: pickedImage == null 
                        ? const Icon(Icons.person, size: 64, color: Colors.grey) 
                        : null,
                  ),

                  const SizedBox(height: 32),

                  // UPLOAD IMAGEボタン
                  Container(
                      width: double.infinity, // 💡 画面幅に統一
                      height: 48,
                      padding: EdgeInsets.zero, 
                      decoration: BoxDecoration(
                          color: Colors.white, 
                          border: Border.all(color: Colors.black, width: 1),
                          boxShadow: const [
                              BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                          ],
                      ),
                      child: ElevatedButton(
                          onPressed: onUploadImagePressed,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          child: const Text(
                              'UPLOAD IMAGE',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Noto Sans JP',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                              ),  
                          ),
                      ),
                  ),
                  
                  const SizedBox(height: 24),

                  // CREATE ACCOUNTボタン
                  Container(
                    width: double.infinity,
                    height: 52, // 💡 少し高さを出して押しやすく
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onCreateAccountPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC5B13),
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        side: const BorderSide(color: Colors.black, width: 1),
                        elevation: 0,
                      ),
                      child: const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // RETURN TO LOGINボタン
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                        color: Colors.white, 
                        border: Border.all(color: Colors.black, width: 1),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                        ],
                    ),
                    child: ElevatedButton(
                        onPressed: onReturnToLoginPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        child: const Text(
                          'RETURN TO LOGIN',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Noto Sans JP',
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                          ),
                        ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}