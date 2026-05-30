import 'package:flutter/material.dart';

import 'common_layout.dart';
import 'package:qr_flutter/qr_flutter.dart'; // qrコード表示用
import 'package:flutter/services.dart'; // コピー用
import 'return_button.dart';

class QrcodePage extends StatefulWidget {
  final String groupId;
  final String eventId;
  final String eventTitle;
  final int myRole;
  final String arrivalTime;
  final String password;

  const QrcodePage({
    super.key,
    required this.groupId,
    required this.eventId,
    required this.eventTitle,
    required this.myRole,
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
      groupId: widget.groupId,
      eventId: widget.eventId,
      eventTitle: widget.eventTitle,
      myRole: widget.myRole,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 戻るボタン
            ReturnButton(onTap: () {
              Navigator.pop(context);
              debugPrint('1画面戻る');
            }),

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
