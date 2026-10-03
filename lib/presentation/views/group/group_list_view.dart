import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/group_repository.dart';
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
  bool _isLocalViewModel = false;
  String? selectedGroupId;
  int? myRole;

  @override
  void initState() {
    super.initState();

    final parentViewModel = context.read<GroupViewModel?>();
    if (parentViewModel != null) {
      _viewModel = parentViewModel;
    } else {
      _viewModel = GroupViewModel(
        SupabaseGroupRepository(Supabase.instance.client),
      );
      _isLocalViewModel = true;
    }

    _viewModel.addListener(_onViewModelUpdated);
    _viewModel.loadGroups();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdated);
    if (_isLocalViewModel) {
      _viewModel.dispose();
    }
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
                              myRole = null;
                            });
                          }
                        } else {
                          final int? role = await _fetchUserRole(value);

                          if (!context.mounted) return;

                          // role: 1 は一般メンバー（Member）
                          if (role == 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventSelectionHome(
                                  groupId: value,
                                  myRole: role!,
                                ),
                              ),
                            );
                            return;
                          }

                          // 管理者 (role == 0 など) の場合はその場で表示切り替え
                          setState(() {
                            selectedGroupId = value;
                            myRole = role ?? 0;
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