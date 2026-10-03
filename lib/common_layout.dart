import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/views/group/group_list_view.dart';
import 'presentation/views/event/admin/create_event_page.dart';
import 'presentation/views/event/checkin/member_check_in.dart';
import 'presentation/views/ranking/ranking_screen.dart';
import 'presentation/views/event/event_selection_home.dart';

class CommonLayout extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;
  final String? groupId;
  final String? eventId;
  final String? eventTitle;
  final int? myRole;

  const CommonLayout({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.groupId,
    this.eventId,
    this.eventTitle,
    this.myRole,
  });

  static const _bottomNavigationItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 25),
        child: Icon(Icons.group),
      ),
      label: 'group',
    ),
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 25),
        child: Icon(Icons.calendar_month),
      ),
      label: 'event',
    ),
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(top: 25),
        child: Icon(Icons.qr_code),
      ),
      label: 'ranking',
    ),
  ];

  static const Color _themeColor = Colors.deepOrangeAccent;
  static const Color _backgroundColor = Color(0xFFF8F6F6);
  static const Color _borderColor = Color(0xFF1A1C1C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 4.0),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _borderColor, width: 4),
            ),
          ),
          child: _buildAppBar(context),
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      leading: _buildLeftIcons(context),
      title: const Text(
        'AWAKE',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: _buildRightIcons(),
      backgroundColor: _themeColor,
      foregroundColor: Colors.black,
      elevation: 0,
    );
  }

  Widget _buildLeftIcons(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.flag, color: Colors.black),
          onPressed: () {
            _onLeaderPressed(context);
            debugPrint("管理者ボタン");
          },
        ),
        IconButton(
          icon: const Icon(Icons.schedule, color: Colors.black),
          onPressed: () {
            _onMemberPressed(context);
            debugPrint("利用者ボタン");
          },
        ),
      ],
    );
  }

  List<Widget> _buildRightIcons() {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;

    if (currentUser == null) {
      return [
        const Padding(
          padding: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
        )
      ];
    }
    return [
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: GestureDetector(
          onTap: _onProfilePressed,
          child: FutureBuilder<Map<String, dynamic>?>(
            future: client
                .from('profiles')
                .select('avatar_url')
                .eq('id', currentUser.id)
                .maybeSingle(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError ||
                  !snapshot.hasData) {
                return const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                );
              }

              final profileData = snapshot.data ?? {};
              final String? avatarUrl = profileData['avatar_url'];
              final bool hasValidAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

              return CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: hasValidAvatar ? NetworkImage(avatarUrl) : null,
                child: !hasValidAvatar
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              );
            },
          ),
        ),
      ),
    ];
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _themeColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _borderColor, width: 4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black.withValues(alpha: 0.5),
          items: _bottomNavigationItems,
          onTap: (index) => _onNavigationTap(context, index),
        ),
      ),
    );
  }

  void _onNavigationTap(BuildContext context, int index) {
    if (index != 0) {
      if (groupId == null || myRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select group.')),
        );
        return;
      }
    }
    Widget? nextPage;
    switch (index) {
      case 0:
        nextPage = const GroupListPage();
        break;
      case 1:
        if (myRole == 0) {
          nextPage = CreateEventPage(
            groupId: groupId!,
            myRole: myRole!,
          );
        } else {
          if (eventId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select event.')),
            );
            return;
          }
          nextPage = MemberCheckInPage(
            eventId: eventId!,
            eventTitle: eventTitle ?? '',
            groupId: groupId!,
            myRole: myRole!,
          );
        }
        break;
      case 2:
        nextPage = const RankingPreview();
        break;
    }
    if (nextPage != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage!),
      );
    }
  }

  void _onLeaderPressed(BuildContext context) {
    if (myRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select group.')),
      );
      debugPrint('グループが選択されていません');
      return;
    }

    if (myRole == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GroupListPage(initialGroupId: groupId)),
      );
      debugPrint('管理者ページへ移動');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('閲覧権限がありません（管理者のみ利用可能）'),
        ),
      );
      debugPrint('利用者のため遷移不可');
    }
  }

  void _onMemberPressed(BuildContext context) {
    if (groupId == null || myRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select group.')),
      );
      debugPrint('グループが選択されていません');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EventSelectionHome(
          groupId: groupId ?? "",
          myRole: myRole!,
        ),
      ),
    );
    debugPrint('利用者ボタンが押されました');
  }

  void _onProfilePressed() {
    debugPrint('プロフィールボタンが押されました');
  }
}