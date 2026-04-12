import 'package:flutter/material.dart';
import 'login_header_screen.dart'; 
import '../../grouplist_page.dart';

Widget createAccountBody(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFf8f6f6),
    // 💡 SafeArea を入れることで、スマホの時計部分との重なりを防ぎます
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          // 💡 これでヘッダーが横いっぱいに広がります
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            // 🔥 1. ヘッダー（一番上！）
            myHeader(), 

            // 🔥 2. メインコンテンツ（ここから下に余白を作る）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 34),
                  const Text(
                    'CREATE PROFILE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 36,
                      fontFamily: 'Noto Sans JP',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Show the world who you are. Customize your look.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  
                  const SizedBox(height: 30),
                  const Text('USER NAME', style: TextStyle(fontWeight: FontWeight.w900)),
                  
                  // ユーザーネーム入力欄
                  Container(
                    width: 320,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF6B7280)),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter your username',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text('PROFILE PICTURE', style: TextStyle(fontWeight: FontWeight.w900)),

                  // プロフィール画像（丸）
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 64, color: Colors.grey),
                  ),

                  const SizedBox(height: 40),
                  
                  // CREATE ACCOUNTボタン
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GroupListPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC5B13),
                      minimumSize: const Size(320, 56),
                    ),
                    child: const Text('CREATE ACCOUNT', style: TextStyle(color: Colors.white)),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}