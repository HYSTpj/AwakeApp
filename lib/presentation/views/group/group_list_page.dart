import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/group_repository.dart';
import '../../../../models/event.dart';
import '../../../../models/group.dart';
import '../../viewmodels/admin_event_view_model.dart';
import '../../viewmodels/group_view_model.dart';
import '../../../common_layout.dart';
import 'create_add_delete_page.dart';
import 'group_event_header.dart';
import '../event/admin/create_event_page.dart';
import '../event/admin/memberstatus_page.dart';
import '../event/event_selection_home_page.dart';

class GroupListPage extends StatefulWidget {
  final String? initialGroupId;
  // 管理者/メンバー切替時のみ渡される、CommonLayoutのbody/footerスライドイン
  // アニメーション。詳細はCommonLayoutを参照。
  final Animation<double>? bodyTransitionAnimation;

  const GroupListPage({
    super.key,
    this.initialGroupId,
    this.bodyTransitionAnimation,
  });

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  late final GroupViewModel _viewModel;
  late final AdminEventViewModel _adminEventViewModel;
  String? selectedGroupId;
  String? selectedGroupName;
  int? myRole;
  String? selectedEventId;
  String? selectedEventTitle;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<GroupViewModel>();
    _adminEventViewModel = context.read<AdminEventViewModel>();
    _viewModel.addListener(_onViewModelUpdated);
    // initState はビルドフェーズ中に実行されるため、loadGroups() 内の
    // notifyListeners() を同期的に呼ぶと祖先の Provider が dirty になり
    // 「setState() or markNeedsBuild() called during build」を引き起こす。
    // 現在のフレーム描画後まで初回ロードを遅らせることで回避する。
    WidgetsBinding.instance.addPostFrameCallback((_) => _initGroups());
  }

  Future<void> _initGroups() async {
    await _viewModel.loadGroups();
    // initialGroupId が渡されている場合は初期選択
    if (widget.initialGroupId != null && mounted) {
      final groups = _viewModel.state.groups;
      if (groups.any((g) => g.id == widget.initialGroupId)) {
        final role = await _fetchUserRole(widget.initialGroupId!);
        if (mounted && role != null) {
          final g = groups.firstWhere(
            (element) => element.id == widget.initialGroupId,
          );
          setState(() {
            selectedGroupId = widget.initialGroupId;
            selectedGroupName = g.groupName;
            myRole = role;
            selectedEventId = null;
            selectedEventTitle = null;
          });
          unawaited(_adminEventViewModel.loadEvents(widget.initialGroupId!));
        }
      }
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdated);
    super.dispose();
  }

  bool _isShowingError = false;

  void _onViewModelUpdated() {
    if (!mounted) return;

    final errorMessage = _viewModel.state.errorMessage;
    if (errorMessage != null && !_isShowingError) {
      _isShowingError = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        _viewModel.clearError();
        _isShowingError = false;
      });
    }

    setState(() {});
  }

  Future<int?> _fetchUserRole(String groupId) async {
    try {
      final role = await context.read<GroupRepository>().getRole(groupId);
      return role;
    } catch (e) {
      debugPrint('ロール取得エラー: $e');
      return null;
    }
  }

  String _formatArrivalTime(DateTime arrivalTime) {
    return DateFormat('M/dd HH:mm').format(arrivalTime);
  }

  Future<void> _onGroupSelected(Group group) async {
    final role = await _fetchUserRole(group.id);
    if (!mounted) return;

    // ロールが取得できない場合は管理者(0)に偽装せずエラー表示
    if (role == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('権限情報を取得できませんでした')));
      return;
    }

    // 一般メンバー（role == 1）
    if (role == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EventSelectionHome(
            groupId: group.id,
            groupName: group.groupName,
            myRole: role,
          ),
        ),
      );
      return;
    }

    // 管理者の場合はその場で選択
    setState(() {
      selectedGroupId = group.id;
      selectedGroupName = group.groupName;
      myRole = role;
      selectedEventId = null;
      selectedEventTitle = null;
    });
    unawaited(_adminEventViewModel.loadEvents(group.id));

    debugPrint("グループ ${group.id} (役割: $myRole) を選択");
  }

  Future<void> _onCreateAddDelete() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateOrAddOrDeletePage()),
    );

    if (result == true) {
      await _viewModel.loadGroups();
      if (!mounted) return;
      setState(() {
        selectedGroupId = null;
        selectedGroupName = null;
        myRole = null;
        selectedEventId = null;
        selectedEventTitle = null;
      });
    }
  }

  void _onEventSelected(Event event) {
    setState(() {
      selectedEventId = event.id;
      selectedEventTitle = event.title;
    });
  }

  Future<void> _onAddEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventPage(
          groupId: selectedGroupId!,
          groupName: selectedGroupName ?? 'Group',
          myRole: myRole ?? 0,
        ),
      ),
    );
    // 作成成功時は共有 ViewModel 内部で自動再同期される
  }

  @override
  Widget build(BuildContext context) {
    final adminEventState = context.watch<AdminEventViewModel>().state;

    // group.id の重複や、selectedGroupId が現在の一覧に存在しない（グループ再読込中
    // の過渡状態など）場合に DropdownButton のアサーションで落ちないようにするガード。
    final groups = <String, Group>{
      for (final g in _viewModel.state.groups) g.id: g,
    }.values.toList();
    final isLoading = _viewModel.state.isLoading;

    // 選択中グループのイベント一覧。読み込み中・グループ不一致の間は空扱い。
    final isMatchingGroup = adminEventState.selectedGroupId == selectedGroupId;
    final events = isMatchingGroup ? adminEventState.events : const <Event>[];
    final isLoadingEvents = isMatchingGroup && adminEventState.isLoadingEvents;
    final selectedEvent = events.any((e) => e.id == selectedEventId)
        ? events.firstWhere((e) => e.id == selectedEventId)
        : null;

    return CommonLayout(
      showFooter: selectedGroupId != null,
      bodyTransitionAnimation: widget.bodyTransitionAnimation,
      groupId: selectedGroupId,
      groupName: selectedGroupName,
      myRole: myRole,
      eventId: selectedEvent?.id,
      eventTitle: selectedEvent?.title,
      arrivalTime: selectedEvent?.arrivalTime,
      arrivalTimeDisplay: selectedEvent == null
          ? null
          : _formatArrivalTime(selectedEvent.arrivalTime),
      password: selectedEvent?.password,
      qrcodeId: selectedEvent?.qrcodeId,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                GroupEventHeader(
                  groups: groups,
                  selectedGroupId: selectedGroupId,
                  onGroupSelected: _onGroupSelected,
                  onCreateAddDelete: _onCreateAddDelete,
                  events: events,
                  selectedEventId: selectedEventId,
                  onEventSelected: _onEventSelected,
                  onAddEvent: _onAddEvent,
                ),
                Expanded(
                  child: selectedGroupId == null
                      ? const Center(child: Text('グループを選択してください'))
                      : isLoadingEvents
                      ? const Center(child: CircularProgressIndicator())
                      : selectedEvent == null
                      ? const Center(child: Text('イベントを選択してください'))
                      : MemberStatusPage(
                          groupId: selectedGroupId!,
                          eventId: selectedEvent.id,
                          eventTitle: selectedEvent.title,
                          myRole: myRole ?? 1,
                          arrivalTime: _formatArrivalTime(
                            selectedEvent.arrivalTime,
                          ),
                          password: selectedEvent.password ?? '',
                          qrcodeId: selectedEvent.qrcodeId ?? '',
                        ),
                ),
              ],
            ),
    );
  }
}
