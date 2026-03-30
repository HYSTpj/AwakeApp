import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'common_layout.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

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

    return CommonLayout(
      body: Container(
        color: const Color(0xFFF9FAFA), // ほんのりグレーがかった白
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
                      width: 280,
                      height: 280,
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
                              Navigator.pop(context, code);
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
            const SizedBox(height: 32),
            
            // Scan instructions banner
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5C00), // オレンジ
                border: Border.all(color: borderColor, width: 3),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Scan the QR code to check-in',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
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
              width: double.infinity,
              height: 60,
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
                onPressed: () {
                  // TODO: Implement Passcode
                },
                icon: const Icon(Icons.apps, color: Colors.black),
                label: const Text(
                  'ENTER PASSCODE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerPositions() {
    const double size = 300;
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
            top: 0, left: 0,
            child: Container(
              width: length, height: length,
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
            top: 0, right: 0,
            child: Container(
              width: length, height: length,
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
            bottom: 0, left: 0,
            child: Container(
              width: length, height: length,
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
            bottom: 0, right: 0,
            child: Container(
              width: length, height: length,
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
