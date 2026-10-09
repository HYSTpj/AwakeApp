import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/group.dart';
import '../../viewmodels/group_view_model.dart';
import '../../../common_layout.dart';
import 'create_add_delete_view.dart';
import '../event/admin/event_list_view.dart';
import '../event/event_selection_home.dart';

class GroupListPage extends StatefulWidget {
  final String? initialGroupId;

  const GroupListPage({super.key, this.initialGroupId});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  late final GroupViewModel _viewModel;
  String? selectedGroupId;
  String? selectedGroupName;
  int? myRole;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<GroupViewModel>();
    _viewModel.addListener(_onViewModelUpdated);
    _initGroups();
  }

  Future<void> _initGroups() async {
    await _viewModel.loadGroups();
    // initialGroupId が渡されている場合は初期選択
    if (widget.initialGroupId != null && mounted) {
      final groups = _viewModel.state.groups;
      if (groups.any((g) => g.id == widget.initialGroupId)) {
        final role = await _fetchUserRole(widget.initialGroupId!);
        if (mounted && role != null) {
          final g = groups.firstWhere((element) => element.id == widget.initialGroupId);
          setState(() {
            selectedGroupId = widget.initialGroupId;
            selectedGroupName = g.groupName;
            myRole = role;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdated);
    super.dispose();
  }

  void _onViewModelUpdated() {
    if (mounted) setState(() {});
  }

  Future<int?> _fetchUserRole(String groupId) async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return null;

    final response = await client
        .from('groups_memberships')
        .select('role')
        .eq('group_id', groupId)
        .eq('user_id', uid)
        .maybeSingle();

    if (response != null && response['role'] != null) {
      return response['role'] as int;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.state.errorMessage != null) {
      final message = _viewModel.state.errorMessage!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        _viewModel.clearError();
      });
    }

    final groups = _viewModel.state.groups;
    final isLoading = _viewModel.state.isLoading;

    return CommonLayout(
      groupId: selectedGroupId,
      groupName: selectedGroupName,
      myRole: myRole,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGroupId,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 28),
                      hint: const Text(
                        'GROUP NAME',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1C1C),
                          letterSpacing: 0.5,
                        ),
                      ),
                      items: [
                        ...groups.map((Group group) {
                          return DropdownMenuItem<String>(
                            value: group.id,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  group.groupName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1C1C),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: group.invitationCode));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('copied the invitation code')),
                                    );
                                  },
                                  child: const Icon(Icons.content_copy, color: Colors.black, size: 20),
                                ),
                              ],
                            ),
                          );
                        }),
                        const DropdownMenuItem<String>(
                          value: 'create_add_delete',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CREATE OR ADD OR DELETE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF5C00),
                                ),
                              ),
                              Icon(Icons.add_box, color: Color(0xFFFF5C00)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (String? value) async {
                        if (value == null) return;

                        if (value == 'create_add_delete') {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateOrAddOrDeletePage(),
                            ),
                          );

                          if (result == true) {
                            await _viewModel.loadGroups();
                            if (!mounted) return;
                            setState(() {
                              selectedGroupId = null;
                              selectedGroupName = null;
                              myRole = null;
                            });
                          }
                        } else {
                          final int? role = await _fetchUserRole(value);
                          if (!context.mounted) return;

                          // ロールが取得できない場合は管理者(0)に偽装せずエラー表示
                          if (role == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('権限情報を取得できませんでした')),
                            );
                            return;
                          }

                          final targetGroup = groups.firstWhere((g) => g.id == value);

                          // 一般メンバー（role == 1）
                          if (role == 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventSelectionHome(
                                  groupId: value,
                                  groupName: targetGroup.groupName, // 💡 正しいグループ名を渡す
                                  myRole: role,
                                ),
                              ),
                            );
                            return;
                          }

                          // 管理者の場合はその場で選択
                          setState(() {
                            selectedGroupId = value;
                            selectedGroupName = targetGroup.groupName;
                            myRole = role;
                          });

                          debugPrint("グループ $value (役割: $myRole) を選択");
                        }
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: selectedGroupId == null
                      ? const Center(
                          child: Text('Select group'),
                        )
                      : EventListPage(
                          groupId: selectedGroupId!,
                        ),
                ),
              ],
            ),
    );
  }
}