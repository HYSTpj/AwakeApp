import 'package:flutter/material.dart';
import '../domain/group_entity.dart';

// 共通の基底クラス
abstract class BaseGroupViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  set errorMessage(String? value) => _errorMessage = value;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}

class CreateGroupViewModel extends BaseGroupViewModel {
  final GroupRepository _repository;

  CreateGroupViewModel(this._repository);

  // Viewからの命令を受けて実行(加入に成功したか失敗したかを出力)
  Future<bool> createGroup(
    String userId,
    String groupName
  ) async {
    setLoading(true);
    setError(null); // エラークリア

    if (groupName.trim().isEmpty || userId.isEmpty) {
      setError('Please enter a new group name.');
      setLoading(false);
      return false;
    }

    try {
      await _repository.setGroup(
        userId: userId,
        groupName: groupName.trim()
      );
      setLoading(false);
      return true;
    } catch (e) {
      setError('Failed to create group: $e');
      setLoading(false);
      return false;
    }
  }
}


class AddGroupViewModel extends BaseGroupViewModel {
  final GroupRepository _repository;

  AddGroupViewModel(this._repository);

  // Viewからの命令を受けて実行(加入に成功したか失敗したかを出力)
  Future<bool> addGroup (
    String userId,
    String groupId
  ) async {
    setLoading(true);
    setError(null);

    if (groupId.trim().isEmpty || userId.isEmpty) {
      setError('Please enter invitation code.');
      setLoading(false);
      return false;
    }

    try {
      final currentGroups = await _repository.getGroups(userId);
      final alreadyJoin = currentGroups.any((group) => group.groupId == groupId.trim());

      if (alreadyJoin) {
        setError('You have already joined this group.');
        setLoading(false);
        return false;
      }

      await _repository.addGroup(
        userId: userId,
        groupId: groupId.trim()
      );
      setLoading(false);
      return true;
    } catch (e) {
      setError('Failed to join group: $e');
      setLoading(false);
      return false;
    }
  }
}


class DeleteGroupViewModel extends BaseGroupViewModel {
  final GroupRepository _repository;

  DeleteGroupViewModel(this._repository);

  // Viewからの命令を受けて実行(加入に成功したか失敗したかを出力)
  Future<bool> deleteGroup(
    String userId,
    String groupId
  ) async {
    setLoading(true);
    setError(null);

    if (groupId.trim().isEmpty || userId.isEmpty) {
      setError('Please enter group ID.');
      setLoading(false);
      return false;
    }

    try {
      await _repository.deleteGroup(
        userId: userId,
        groupId: groupId.trim()
      );
      setLoading(false);
      return true;
    } catch (e) {
      setError('Failed to leave group: $e');
      setLoading(false);
      return false;
    }
  }
}


class GroupListViewModel extends BaseGroupViewModel {
  final GroupRepository _repository;

  // 状態(State)を管理
  List<GroupEntity> _groups = [];
  List<GroupEntity> get groups => _groups;

  GroupListViewModel(this._repository);

  // Viewからの命令を受けて実行(加入に成功したか失敗したかを出力)
  Future<void> getGroups(String userId) async {
    setLoading(true);
    setError(null);

    if (userId.isEmpty) {
      setError('User ID is required.');
      setLoading(false);
      _groups = [];
      return;
    }

    try {
      _groups = await _repository.getGroups(userId);
      setLoading(false);
    } catch (e) {
      setError('Failed to load groups: $e');
      setLoading(false);
      _groups = [];
    }
  }
}