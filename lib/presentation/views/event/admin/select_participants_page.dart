import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common_layout.dart';
import '../../../../../../presentation/viewmodels/admin_event_view_model.dart';

const _kBorderSide = BorderSide(width: 3, color: Color(0xFF475569));

class UserTile extends StatelessWidget {
  final String nickname;
  final String userId;
  final String avatarUrl;
  final bool isAttending;
  final VoidCallback? onToggle;

  const UserTile({
    super.key,
    required this.nickname,
    required this.userId,
    required this.avatarUrl,
    this.isAttending = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // アバター
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl.isEmpty
                  ? const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // 名前とID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('@$userId', style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 12)),
              ],
            ),
          ),
          // スイッチ部分
          Column(
            children: [
              const Text('ATTENDING', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
              Switch(
                value: isAttending,
                onChanged: (bool value) {
                  onToggle?.call();
                },
                activeThumbColor: const Color(0xFFFF5C00),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SelectParticipantsPage extends StatefulWidget {
  final String groupId;
  final String title;
  final String destinationName;
  final double? latitude;
  final double? longitude;
  final DateTime arrivalTime;
  final String password;
  final int? myRole;

  const SelectParticipantsPage({
    super.key,
    required this.groupId,
    required this.title,
    required this.destinationName,
    this.latitude,
    this.longitude,
    required this.arrivalTime,
    required this.password,
    this.myRole,
  });

  @override
  State<SelectParticipantsPage> createState() => _SelectParticipantsPageState();
}

class _SelectParticipantsPageState extends State<SelectParticipantsPage> {
  final Set<String> _selectedMembers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminEventViewModel>().loadGroupMembers(widget.groupId);
    });
  }

  String _generateSecureToken([int length = 32]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _saveAndNavigate() async {
    final viewModel = context.read<AdminEventViewModel>();
    final state = viewModel.state;

    // 作成中・読み込み中・エラー時は操作抑止
    if (state.isCreatingEvent || state.isLoadingMembers) return;

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メンバーを選んでください')),
      );
      return;
    }

    final qrcodeId = 'qr_${_generateSecureToken(32)}';

    final eventId = await viewModel.createEventWithParticipants(
      groupId: widget.groupId,
      title: widget.title,
      destinationName: widget.destinationName,
      latitude: widget.latitude,
      longitude: widget.longitude,
      qrcodeId: qrcodeId,
      password: widget.password,
      arrivalTime: widget.arrivalTime,
      participantUserIds: _selectedMembers.toList(),
    );

    if (!mounted) return;

    if (eventId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベントを作成しました')),
      );
      Navigator.pop(context, true);
    } else if (viewModel.state.createEventError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('イベント作成失敗: ${viewModel.state.createEventError}')),
      );
    }
  }

  Widget _buildMemberList(AdminEventState state) {
    // 1. 取得失敗時のエラー表示
    if (state.membersError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
              const SizedBox(height: 8),
              Text(
                'メンバーの取得に失敗しました\n${state.membersError}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AdminEventViewModel>().loadGroupMembers(widget.groupId);
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('再試行'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C00),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 2. 正常取得完了かつメンバーが0件の場合
    if (state.groupMembers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: Text('メンバーがいません')),
      );
    }

    // 3. 正常取得完了（リスト表示）
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: state.groupMembers.map((member) {
        final memberName = member.nickname.isNotEmpty ? member.nickname : 'No Name';
        final memberId = member.id;
        final memberAvatar = member.avatarUrl ?? '';
        final isSelected = _selectedMembers.contains(memberId);

        return UserTile(
          nickname: memberName,
          userId: memberId,
          avatarUrl: memberAvatar,
          isAttending: isSelected,
          onToggle: () {
            setState(() {
              if (isSelected) {
                _selectedMembers.remove(memberId);
              } else {
                _selectedMembers.add(memberId);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminEventViewModel>();
    final state = viewModel.state;

    // 画面整合性ガード：現在のグループとStateのIDが一致していない、または読み込み中はローディング
    final isMatchingGroup = state.selectedMembersGroupId == widget.groupId;
    final isLoading = state.isLoadingMembers || !isMatchingGroup;

    return CommonLayout(
      groupId: widget.groupId,
      myRole: widget.myRole,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 戻るボタン
                  Padding(
                    padding: const EdgeInsets.only(left: 14, top: 9),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(side: _kBorderSide),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -1),
                          child: const Text(
                            'Select Participants',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                              leadingDistribution: TextLeadingDistribution.even,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: const BoxDecoration(color: Colors.black),
                              child: Text(
                                '${_selectedMembers.length} SELECTED',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontFamily: 'Space Grotesk',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.48,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // メンバーリスト（エラー / 0件 / リストを明確に分離）
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 3, color: Color(0xFF475569)),
                      ),
                    ),
                    child: _buildMemberList(state),
                  ),

                  // SAVEボタン
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        onTap: (state.isCreatingEvent || state.membersError != null)
                            ? null
                            : _saveAndNavigate,
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: (state.isCreatingEvent || state.membersError != null)
                                ? Colors.grey
                                : const Color(0xFFFF5C00),
                            shape: const RoundedRectangleBorder(side: _kBorderSide),
                            shadows: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: const Offset(4, 4),
                              ),
                            ],
                          ),
                          child: state.isCreatingEvent
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'SAVE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Space Grotesk',
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  @override
  void didUpdateWidget(SelectParticipantsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.groupId != widget.groupId) {
      setState(() {
        _selectedMembers.clear(); // 💡 _selectedUserIds ではなく _selectedMembers をクリア
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AdminEventViewModel>().loadGroupMembers(widget.groupId);
        }
      });
    }
  }
}