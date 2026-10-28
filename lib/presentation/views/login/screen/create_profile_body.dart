import 'package:flutter/material.dart';
import 'login_header.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_application_1/l10n/app_localizations.dart';

Widget createAccountBody(
  BuildContext context, {
  required VoidCallback onUploadImagePressed,
  required VoidCallback onCreateAccountPressed,
  required VoidCallback onReturnToLoginPressed,
  required TextEditingController userNameController,
  required dynamic pickedImage,
}) {
  return Scaffold(
    backgroundColor: const Color(0xFFf8f6f6),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          // ヘッダーは固定
          myHeader(context),

          // フォーム部分のみスクロール
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      AppLocalizations.of(context)!.createProfile,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 32,
                        fontFamily: 'Noto Sans JP',
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    Text(
                      AppLocalizations.of(context)!.createProfileDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ユーザーネーム入力欄
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      child: TextField(
                        controller: userNameController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.enterUserName,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.profilePicture,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // プロフィール画像
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        image: pickedImage != null
                            ? DecorationImage(
                                image: kIsWeb
                                    ? MemoryImage(
                                        pickedImage as Uint8List,
                                      )
                                    : FileImage(
                                        pickedImage as File,
                                      ) as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: pickedImage == null
                          ? const Icon(
                              Icons.person,
                              size: 64,
                              color: Colors.grey,
                            )
                          : null,
                    ),

                    const SizedBox(height: 32),

                    // UPLOAD IMAGEボタン
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onUploadImagePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.uploadImage,
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
                      height: 52,
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onCreateAccountPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC5B13),
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          side: const BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.createAccount,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // RETURN TO LOGINボタン
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onReturnToLoginPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.returnToLogin,
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
            ),
          ),
        ],
      ),
    ),
  );
}