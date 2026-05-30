import 'package:flutter/material.dart';
import 'common_layout.dart';
import 'data/event_repository.dart';

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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl) // 画像がある時は写真を表示
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
  final String eventId;
  final String groupId; 
  final String eventTitle;
  final int myRole;
  const SelectParticipantsPage({
    super.key,
    required this.groupId,
    required this.eventId,
    required this.eventTitle,
    required this.myRole,
  });

  @override
  State<SelectParticipantsPage> createState() => _SelectParticipantsPageState();
}

class _SelectParticipantsPageState extends State<SelectParticipantsPage> {
  final EventRepository _repository = EventRepository();
  List<Map<String, dynamic>> _allMembers = [];
  late Set<String> _selectedMembers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

Future<void> _loadMembers() async {
    try {
      final members = await _repository.getGroupMembers(widget.groupId);
      setState(() {
        _allMembers = members;
        _selectedMembers = {};
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('メンバー取得エラー: $e');
      setState(() {
        _selectedMembers = {};
        _isLoading = false;
      });
    }
  }

  // 1. 保存と遷移のメソッドを追加
  Future<void> _saveAndNavigate() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _repository.updateEventParticipants(
        widget.eventId,
        _selectedMembers.toList(),
      );

      if (!mounted) return;

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      debugPrint('保存エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      groupId: widget.groupId,
      eventId: widget.eventId,
      eventTitle: widget.eventTitle,
      myRole: widget.myRole,
      body: _isLoading 
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
                  // メインタイトル
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
                  // カウントラベル
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

            // メンバーリスト
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 3, color: Color(0xFF475569)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _allMembers.map((member) {
                  final memberName = member['nickname'] ?? 'No Name';
                  final memberId = member['uid'] ?? '';
                  final memberAvatar = member['avatar_url'] ?? '';
                  final isSelected = _selectedMembers.contains(memberId); 
                  
                  return UserTile(
                    nickname: memberName,
                    userId: memberId,
                    avatarUrl: memberAvatar,
                    isAttending: isSelected,
                    onToggle: () {
                      // ボタンが押された時の処理
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
              ),
            ),

            // SAVEボタン
          Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: _saveAndNavigate,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFF5C00),
                      shape: const RoundedRectangleBorder(side: _kBorderSide),
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: const Text(
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
            )
          ],
        ),
      ),
    );
  }
}
