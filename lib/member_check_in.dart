import 'package:flutter/material.dart';

import 'common_layout.dart';
import 'widgets/statusbutton.dart';
import 'qr_scanner_page.dart';
import 'viewmodels/member_check_in_viewmodel.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'data/group_repository.dart';

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
  late String _currentGroupId; // 現在表示中のグループID
  List<Map<String, dynamic>> _myGroups = [];  // 所属グループ全リスト

  @override
  void initState() {
    super.initState();
    _currentGroupId = widget.groupId; // 初期値
    _viewModel = MemberCheckInViewModel(
      eventId: widget.eventId,
      groupId: _currentGroupId,
    );
    _initializeData();
  }

  Future<void> _initializeData() async 
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final groups = await GroupRepository().getGroups(uid);
        if (mounted) {
          setState(() {
            _myGroups = groups;
          });
        }
      } catch (e) {
        debugPrint('Group load error: $e');
      }
    }

    final errorMessage = await _viewModel.loadData();
    
    // Copilot指摘解決: もしログインエラー（未認証状態）が返ってきたら、強制的にダイアログを出して戻る
    if (errorMessage != null && mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false, // 周りをタップして閉じられないようにブロック
        builder: (context) {
          return AlertDialog(
            title: const Text('ログインが必要です'),
            content: const Text('メンバーのチェックインを利用するには、ログインしてください。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                  Navigator.of(context).pop(); // 元の画面へ戻る
                },
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      );
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
          value: _myGroups.any((g) => g['group_id'] == _currentGroupId) ? _currentGroupId : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 28),
          items: _myGroups.map((group) {
            return DropdownMenuItem<String>(
              value: group['group_id'],
              child: Text(
                group['group_name'] ?? 'Unnamed Group',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            );
          }).toList(),
          onChanged: (String? newGroupId) {
            if (newGroupId != null && newGroupId != _currentGroupId) {
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
    if (_viewModel.isCheckInPressed) return;

    // QRスキャナーまたはパスコード画面へ遷移して結果を受け取る
    final scannedResult = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerPage(),
      ),
    );

    if (scannedResult != null) {
      final type = scannedResult['type'];
      final value = scannedResult['value'];
      
      if (type == null || value == null) return;

      final isValid = await _viewModel.verifyAndCheckIn(type, value);

      if (mounted) {
        if (isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('チェックインが完了しました！', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final errorMsg = type == 'qrcode' ? '無効なQRコードです。' : 'パスコードが間違っています。';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ViewModelの変更を監視してUIを自動再描画
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return CommonLayout(
          body: SingleChildScrollView(
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
                  WakeUpButton(isPressed: _viewModel.isWakeUpPressed, onTap: _viewModel.toggleWakeUp),
                  const SizedBox(height: 16),
                  DepartureButton(
                    isSelected: _viewModel.isDeparturePressed,
                    onTap: _viewModel.toggleDeparture,
                  ),
                  const SizedBox(height: 16),
                  CheckInButton(isPressed: _viewModel.isCheckInPressed, onTap: _handleCheckIn),
                  const SizedBox(height: 16),
                  ReportLateButton(
                    onTap: () {
                      // TODO: REPORT LATEボタンがタップされたときの処理を実装する
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

class GroupNameDropdown extends StatelessWidget {
  final String groupName;
  
  const GroupNameDropdown({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF1A1C1C);
    
    return Container(
      width: 362,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            groupName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: borderColor,
              letterSpacing: 0.5,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: borderColor, size: 28),
        ],
      ),
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
