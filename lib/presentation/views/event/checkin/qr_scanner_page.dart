import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../common_layout.dart';
import 'passcode_entry_page.dart';

class QRScannerPage extends StatefulWidget {
  final String groupId;
  final String eventId;
  final String eventTitle;
  final int myRole;

  const QRScannerPage({
    super.key,
    required this.groupId,
    required this.eventId,
    required this.eventTitle,
    required this.myRole,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanned = false; // 重複ポップを防ぐ

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1A1C1C);
    final scannerSize = (MediaQuery.sizeOf(context).width - 48).clamp(
      280.0,
      320.0,
    );

    return CommonLayout(
      groupId: widget.groupId,
      eventId: widget.eventId,
      eventTitle: widget.eventTitle,
      myRole: widget.myRole,
      body: Container(
        color: const Color(0xFFF9FAFA), // ほんのりグレーがかった白
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              children: [
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderColor, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: borderColor,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: borderColor),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Scanner View
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Camera Area
                        Container(
                          width: scannerSize,
                          height: scannerSize,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            color: Colors.black12, // バックグラウンド
                          ),
                          child: MobileScanner(
                            controller: controller,
                            onDetect: (capture) {
                              if (_isScanned) return;
                              final List<Barcode> barcodes = capture.barcodes;
                              if (barcodes.isNotEmpty) {
                                final String? code = barcodes.first.rawValue;
                                if (code != null) {
                                  setState(() {
                                    _isScanned = true;
                                  });
                                  Navigator.pop(context, {
                                    'type': 'qrcode',
                                    'value': code,
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        // Orange Corners
                        _buildCornerPositions(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Scan instructions banner
                SizedBox(
                  width: scannerSize,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5C00), // オレンジ
                      border: Border.all(color: borderColor, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Scan the QR code to check-in',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Enter Passcode button
                Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: borderColor,
                        offset: Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  width: scannerSize,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: const BorderSide(color: borderColor, width: 3),
                      ),
                    ),
                    onPressed: () async {
                      // パスコード入力画面を push で開き、結果を受け取る
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PasscodeEntryPage(
                            groupId: widget.groupId,
                            eventId: widget.eventId,
                            eventTitle: widget.eventTitle,
                            myRole: widget.myRole,
                          ),
                        ),
                      );

                      if (!context.mounted) return;

                      // 受け取った結果(result)を持って、QRScannerPage自体を pop し、呼び出し元の大元（Home）へ返す
                      if (result != null) {
                        Navigator.pop(context, result);
                      }
                    },
                    icon: const Icon(Icons.apps, color: Colors.black),
                    label: const Text(
                      'ENTER PASSCODE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCornerPositions() {
    final size = (MediaQuery.sizeOf(context).width - 48).clamp(280.0, 320.0);
    const Color cornerColor = Color(0xFFFF5C00); // オレンジ
    const double borderW = 8.0;
    const double length = 50.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Top Left
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: length,
              height: length,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: cornerColor, width: borderW),
                  left: BorderSide(color: cornerColor, width: borderW),
                ),
              ),
            ),
          ),
          // Top Right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: length,
              height: length,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: cornerColor, width: borderW),
                  right: BorderSide(color: cornerColor, width: borderW),
                ),
              ),
            ),
          ),
          // Bottom Left
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: length,
              height: length,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cornerColor, width: borderW),
                  left: BorderSide(color: cornerColor, width: borderW),
                ),
              ),
            ),
          ),
          // Bottom Right
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: length,
              height: length,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: cornerColor, width: borderW),
                  right: BorderSide(color: cornerColor, width: borderW),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
