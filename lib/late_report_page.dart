import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'viewmodels/late_report_viewmodel.dart';
import 'common_layout.dart';

class LateReportPage extends StatefulWidget {
  final String reportId;
  final String eventId;

  const LateReportPage({
    super.key,
    required this.reportId,
    required this.eventId,
  });

  @override
  State<LateReportPage> createState() => _LateReportPageState();
}

class _LateReportPageState extends State<LateReportPage> {
  late final LateReportViewModel _viewModel;
  final TextEditingController _reasonController = TextEditingController();
  final String currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? 'user_${FirebaseAuth.instance.currentUser?.uid.substring(0, 4) ?? 'anon'}';

  @override
  void initState() {
    super.initState();
    _viewModel = LateReportViewModel(
      reportId: widget.reportId,
      eventId: widget.eventId,
      userId: FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
    );
    _reasonController.addListener(() {
      _viewModel.setReason(_reasonController.text);
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final success = await _viewModel.submitReport();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('遅刻報告を保存・送信しました！', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // 成功したら前の画面(チェックイン画面)に戻る
    } else if (mounted && _viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1A1C1C);
    const orangeColor = Color(0xFFFF5C00);

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return CommonLayout(
          body: Container(
            color: const Color(0xFFF9FAFA),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 60, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. トップアプレット枠 (User Info, Back Button, Status)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 戻るボタン (ユーザー要望)
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: borderColor, width: 3),
                            boxShadow: const [
                              BoxShadow(color: borderColor, offset: Offset(3, 3), blurRadius: 0),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back, color: borderColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // User Info
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E3A40),
                                border: Border.all(color: borderColor, width: 2),
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '@$currentUserName',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: borderColor, overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(
                                    _viewModel.locationName.split(',').first, // "BROOKLYN" のみ抽出
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: orangeColor, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // LATE REPORT Label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: borderColor,
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: const Text(
                          'LATE REPORT',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  // 2. カメラ・証拠枠 (CAPTURE EVIDENCE)
                  GestureDetector(
                    onTap: () {
                      if (!_viewModel.isUploading) _viewModel.capturePhoto();
                    },
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        border: Border.all(color: borderColor, width: 4),
                      ),
                      child: _viewModel.evidencePhoto != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(_viewModel.evidencePhoto!, fit: BoxFit.cover),
                                if (_viewModel.isUploading)
                                  Container(
                                    color: const Color(0x80000000),
                                    child: const Center(
                                      child: CircularProgressIndicator(color: orangeColor),
                                    ),
                                  )
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.camera_alt, size: 64, color: orangeColor),
                                SizedBox(height: 12),
                                Text(
                                  'CAPTURE EVIDENCE',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: borderColor, letterSpacing: -0.5),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. 遅刻理由入力 (REASON FOR BEING LATE)
                  const Text(
                    'REASON FOR BEING LATE',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: orangeColor, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderColor, width: 4),
                    ),
                    child: TextField(
                      controller: _reasonController,
                      enabled: !_viewModel.isUploading,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: borderColor),
                      decoration: const InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFA1A1AA), fontStyle: FontStyle.italic),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. 좌표確認パネル (VERIFIED COORDINATES)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'VERIFIED COORDINATES',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: borderColor),
                      ),
                      Text(
                        '● GPS SECURE',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF10B981)), // Green
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      border: Border.all(color: borderColor, width: 3),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: orangeColor, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _viewModel.locationName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: borderColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_viewModel.latitude != null && _viewModel.longitude != null)
                          Text(
                            '${_viewModel.latitude!.toStringAsFixed(4)}° N\n${_viewModel.longitude!.toStringAsFixed(4)}° E',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6B7280), height: 1.2),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 5. 送信ボタン (ユーザー要望追加)
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: const BorderSide(color: borderColor, width: 3),
                        ),
                      ),
                      onPressed: _viewModel.isUploading ? null : _onSubmit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _viewModel.isUploading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text(
                                'SUBMIT REPORT',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                              ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 6. フッター タイムスタンプ
                  Center(
                    child: Text(
                      'SUBMITTED REPORTS ARE FINAL. TIMESTAMP: ${DateFormat("hh:mm a 'EST'").format(DateTime.now())}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
