import 'package:flutter/material.dart';

import '../common_layout.dart';
import 'package:qr_flutter/qr_flutter.dart'; // qrコード表示用
import 'package:flutter/services.dart'; // コピー用

class QrcodePage extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String arrivalTime;
  final String password;

  const QrcodePage({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.arrivalTime,
    required this.password,
  });

  @override
  State<QrcodePage> createState() => _QrcodePageState();
}

class _QrcodePageState extends State<QrcodePage> {
  // privateに設定

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      // 共通レイアウトを使用
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 要素を画面内に均等に配置する
          children: [
            // 戻るボタン
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.topLeft, // 左上に表示
              child: Container(
                margin: const EdgeInsets.only(top: 10, left: 5),
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // memberstatus_pageに戻る
                    debugPrint('1画面戻る');
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // QRcode表示
            Flexible(
              // 空いたスペースに収まるように
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  color: Colors.white,
                ),
                width: double.infinity,

                // イベント情報
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 最小限の高さにする
                  children: [
                    Flexible(
                      child: QrImageView(
                        // QRコード取得
                        data: widget.eventId,
                        version: QrVersions.auto,
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'EVENT NAME : ${widget.eventTitle}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis, // 長すぎたら...にする
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 2,
                      height: 20,
                    ), // 間の黒線追加
                    Text(
                      'MEETING TIME : ${widget.arrivalTime}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 2,
                      height: 20,
                    ), // 間の黒線追加
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ID表示
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                color: Colors.white,
              ),
              width: double.infinity,
              child: Center(
                child: Text(
                  'Check In ID : ${widget.password}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis, // 長すぎたら...にする
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Copy ID ボタン
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: widget.password));

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Copied ID')));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                width: double.infinity,
                child: const Center(
                  child: Text(
                    'COPY ID',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
