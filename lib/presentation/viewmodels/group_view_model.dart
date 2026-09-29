import 'package:flutter/foundation.dart';
import '../../data/repositories/group_repository.dart';
import '../../models/group.dart';

class GroupState {
  final List<Group> groups;
  final bool isLoading;
  final String? errorMessage;

  const GroupState({
    this.groups = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  GroupState copyWith({
    List<Group>? groups,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GroupState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class GroupViewModel extends ChangeNotifier {
  final GroupRepository _groupRepository;
  GroupState _state = const GroupState();

  GroupViewModel(this._groupRepository);

  GroupState get state => _state;

  /// 所属グループ内に同名のグループが存在するか確認
  bool isGroupNameExists(String name) {
    final trimmedName = name.trim().toLowerCase();
    return _state.groups.any(
      (group) => group.groupName.trim().toLowerCase() == trimmedName,
    );
  }

  Future<void> loadGroups() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final groups = await _groupRepository.getGroups();
      _state = _state.copyWith(groups: groups, isLoading: false);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
    }
  }

  Future<bool> createGroup(String name) async {
    final trimmedName = name.trim();

    // 1. 空文字バリデーション
    if (trimmedName.isEmpty) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'グループ名を入力してください',
      );
      notifyListeners();
      return false;
    }

    // 2. グループ名の重複チェック
    if (isGroupNameExists(trimmedName)) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: '同じ名前のグループが既に存在します',
      );
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final newGroup = await _groupRepository.createGroup(trimmedName);
      _state = _state.copyWith(
        groups: [..._state.groups, newGroup],
        isLoading: false,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinGroupByCode(String code) async {
    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: '招待コードを入力してください',
      );
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final success = await _groupRepository.joinGroupByCode(trimmedCode);
      if (success) {
        await loadGroups();
        return true;
      } else {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: '無効な招待コードです',
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteOrLeaveGroup(String groupId) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _groupRepository.leaveOrDeleteGroup(groupId);
      _state = _state.copyWith(
        groups: _state.groups.where((g) => g.id != groupId).toList(),
        isLoading: false,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
      return false;
    }
  }

  // エラーメッセージをクリアする
  void clearError() {
    if (_state.errorMessage != null) {
      _state = _state.copyWith(clearError: true);
      notifyListeners();
    }
  }
}