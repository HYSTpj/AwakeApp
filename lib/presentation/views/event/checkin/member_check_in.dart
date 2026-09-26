import 'package:flutter/material.dart';

import '../../../../common_layout.dart';
import '../../../../widgets/statusbutton.dart';
import 'qr_scanner_page.dart';
import '../../../viewmodels/member_check_in_viewmodel.dart';
import 'late_report_page.dart';

class MemberCheckInPage extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String groupId;

  const MemberCheckInPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.groupId,
  });

  @override
  State<MemberCheckInPage> createState() => _MemberCheckInPageState();
}

class _MemberCheckInPageState extends State<MemberCheckInPage> {
  late final MemberCheckInViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MemberCheckInViewModel(
      eventId: widget.eventId,
      groupId: widget.groupId,
    );
    _initializeData();
  }

  Future<void> _initializeData() async {
    final error = await _viewModel.loadData();

    if (error != null && mounted) {
      switch (error) {
        case CheckInLoadError.notLoggedIn:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ログインが必要です。再度ログインしてください。')),
          );
          Navigator.of(context).pop();
          break;

        case CheckInLoadError.notParticipant:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('あなたはこのイベントの参加者として登録されていません。')),
          );
          Navigator.of(context).pop();
          break;

        case CheckInLoadError.fetchFailed:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('データの取得に失敗しました。通信環境を確認してください。')),
          );
          break;
      }
    }
  }

  Widget _buildGroupDropdown() {
    return Container(
      width: 362,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF1A1C1C), width: 4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _viewModel.myGroups.any((g) => g['group_id'] == _viewModel.groupId) ? _viewModel.groupId : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 28),
          items: _viewModel.myGroups.map((group) {
            return DropdownMenuItem<String>(
              value: group['group_id'],
              child: Text(
                group['group_name'] ?? 'Unnamed Group',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            );
          }).toList(),
          onChanged: (String? newGroupId) {
            if (newGroupId != null && newGroupId != _viewModel.groupId) {
              // 現在の画面を閉じて、イベント一覧（EventListPage）に戻る
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleCheckIn() async {
    if (_viewModel.isCheckInPressed || !_viewModel.isParticipant) return;

    // QRスキャナーまたはパスコード画面へ遷移して結果を受け取る
    final scannedResult = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(
          groupId: widget.groupId,
          eventId: widget.eventId,
          eventTitle: widget.eventTitle,
          myRole: 1,
        ),
      ),
    );

    if (scannedResult != null) {
      final type = scannedResult['type'];
      final value = scannedResult['value'];
      
      if (type == null || value == null) return;

      final ctx = context;
      final isValid = await _viewModel.verifyAndCheckIn(type, value);
      if (!ctx.mounted) return;

      if (isValid) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('チェックインが完了しました！', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMsg = type == 'qrcode' ? '無効なQRコードです。' : 'パスコードが間違っています。';
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(errorMsg, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 取得失敗時に表示する再試行ビュー
  Widget _buildErrorRetryView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFF93000A)),
            const SizedBox(height: 16),
            const Text(
              'データの取得に失敗しました',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '通信環境を確認し、もう一度お試しください。',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeData,
              icon: const Icon(Icons.refresh),
              label: const Text('再読み込み'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ViewModelの変更を監視してUIを自動再描画
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return CommonLayout(
          body: _viewModel.loadError == CheckInLoadError.fetchFailed
              ? _buildErrorRetryView()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildGroupDropdown(),
                        const SizedBox(height: 24),
                        CurrentStatusPanel(status: _viewModel.selectedStatus),
                        const SizedBox(height: 16),
                        WakeUpButton(
                          isPressed: _viewModel.isWakeUpPressed,
                          onTap: _viewModel.isParticipant ? _viewModel.toggleWakeUp : null,
                        ),
                        const SizedBox(height: 16),
                        DepartureButton(
                          isSelected: _viewModel.isDeparturePressed,
                          onTap: _viewModel.isParticipant ? _viewModel.toggleDeparture : null,
                        ),
                        const SizedBox(height: 16),
                        CheckInButton(
                          isPressed: _viewModel.isCheckInPressed,
                          onTap: _viewModel.isParticipant ? _handleCheckIn : null,
                        ),
                        const SizedBox(height: 16),
                        ReportLateButton(
                          onTap: !_viewModel.isParticipant
                              ? null
                              : () async {
                                  final ctx = context;
                                  final reportId = await _viewModel.getOrCreateReportId();
                                  if (!ctx.mounted) return;

                                  if (reportId == null) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      const SnackBar(
                                        content: Text('ログイン情報が見つかりません。再度ログインしてください。', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  final res = await Navigator.push<bool>(
                                    ctx,
                                    MaterialPageRoute(
                                      builder: (context) => LateReportPage(reportId: reportId, eventId: widget.eventId),
                                    ),
                                  );

                                  if (res == true) {
                                    await _viewModel.loadData();
                                  }
                                },
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

class CurrentStatusPanel extends StatelessWidget {
  const CurrentStatusPanel({super.key, required this.status});

  final StatusButtonType status;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1A1C1C);

    return SizedBox(
      width: 362,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          border: Border.all(color: borderColor, width: 4),
        ),
        padding: const EdgeInsets.all(14),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor, width: 4)),
          ),
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CURRENT\nSTATUS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  color: borderColor,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor, width: 2),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10.5,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColorOf(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${statusOrderOf(status)}: ${statusLabelOf(status)}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: borderColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DepartureButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;
  final String label;

  const DepartureButton({
    super.key,
    this.isSelected = false,
    this.onTap,
    this.label = 'DEPARTURE',
  });

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 362.0;
    const buttonHeight = 90.0;
    const borderColor = Color(0xFF1A1C1C);
    final backgroundColor = isSelected ? const Color(0xFFE5E7EB) : Colors.white;
    final iconAreaColor = isSelected ? Colors.transparent : const Color(0xFFFF5C00);
    final iconColor = const Color(0xFF1A1C1C);
    final rightIcon = isSelected ? Icons.check : Icons.arrow_forward;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50.5,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconAreaColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1C1C),
                        letterSpacing: -1.2,
                        height: 1.333,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(rightIcon, color: iconColor, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckInButton extends StatelessWidget {
  final bool isPressed;
  final VoidCallback? onTap;
  final String label;

  const CheckInButton({
    super.key,
    this.isPressed = false,
    this.onTap,
    this.label = 'CHECK-IN',
  });

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 362.0;
    const buttonHeight = 90.0;
    const borderColor = Color(0xFF1A1C1C);
    final backgroundColor = isPressed
        ? const Color(0xFFE2E2E2)
        : const Color(0xFFFF5C00);
    final iconColor = const Color(0xFF1A1C1C);
    final rightIcon = isPressed ? Icons.check : Icons.arrow_forward;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 53,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on,
                          color: iconColor,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1C1C),
                        letterSpacing: -1.2,
                        height: 1.333,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 24.5,
                  height: 24.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(rightIcon, color: iconColor, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WakeUpButton extends StatelessWidget {
  final bool isPressed;
  final VoidCallback? onTap;
  final String label;

  const WakeUpButton({
    super.key,
    this.isPressed = false,
    this.onTap,
    this.label = 'WAKE UP',
  });

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 362.0;
    const buttonHeight = 90.0;
    const borderColor = Color(0xFF1A1C1C);
    final backgroundColor = isPressed ? const Color(0xFFE5E7EB) : Colors.white;
    final iconAreaColor = isPressed ? Colors.transparent : const Color(0xFFFF5C00);
    final iconColor = const Color(0xFF1A1C1C);
    final rightIcon = isPressed ? Icons.check : Icons.arrow_forward;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54.5,
                      height: 52.6,
                      decoration: BoxDecoration(
                        color: iconAreaColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(Icons.alarm, color: iconColor, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1C1C),
                        letterSpacing: -1.2,
                        height: 1.333,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(rightIcon, color: iconColor, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportLateButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;

  const ReportLateButton({super.key, this.onTap, this.label = 'REPORT LATE'});

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 362.0;
    const buttonHeight = 90.0;
    const borderColor = Color(0xFF1A1C1C);
    const buttonColor = Color(0xFFFFDAD6);
    const iconBackgroundColor = Color(0xFF93000A);
    const iconColor = Colors.white;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: buttonColor,
              border: Border.all(color: borderColor, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54.6,
                      height: 53,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        border: Border.all(color: borderColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.alarm, color: iconColor, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF93000A),
                        letterSpacing: -1.2,
                        height: 1.333,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFF93000A),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
