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
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final newGroup = await _groupRepository.createGroup(name);
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
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final success = await _groupRepository.joinGroupByCode(code);
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
}