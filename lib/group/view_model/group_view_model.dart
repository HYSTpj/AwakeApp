import '../domain/group_entity.dart';

class CreateGroupViewModel {
  final GroupRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // エラーメッセージを受けっとたか判定するために設定
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CreateGroupViewModel(this._repository);

  // Viewからの命令を受けて実行(加入に成功したか失敗したかを出力)
  Future<bool> createGroup(
    String userId,
    String groupName
  ) async {
    _isLoading = true;

    if (groupName.isNotEmpty && userId.isNotEmpty) {  // group nameとuser idが空でないとき
      try {
        await _repository.setGroup(
          userId: userId,
          groupName: groupName
        );
        _isLoading = false;
        return true;
      } catch (e) {
        _errorMessage = '$e';
        _isLoading = false;
        return false;
      }
    } else {

      _errorMessage = 'Please enter a new group name.';
      _isLoading = false;
      return false;
    }
  }
}


class AddGroupViewModel {
  final GroupRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // エラーメッセージを受けっとたか判定するために設定
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AddGroupViewModel(this._repository);

  // Viewからの命令を受けて実行(加入に成功したか失敗したかを出力)
  Future<bool> addGroup (
    String userId,
    String groupId
  ) async {
    _isLoading = true;

    final currentGroups = await _repository.getGroups(userId);
    final alreadyJoin = currentGroups.any((group) => group.groupId == groupId);

    if (alreadyJoin) {  // 今加入しているグループのidでないかチェック
      _errorMessage = 'You have already joined this group.';
      _isLoading = false;
      return false;
    }

    if (groupId.isNotEmpty && userId.isNotEmpty) {  // group idとuser idが空でないとき
      try {
        await _repository.addGroup(
          userId: userId,
          groupId: groupId
        );
        _isLoading = false;
        return true;
      } catch (e) {
        _errorMessage = '$e';
        _isLoading = false;
        return false;
      }
    } else {

      _errorMessage = 'Please enter invitation code.';
      _isLoading = false;
      return false;
    }
  }
}


class DeleteGroupViewModel {
  final GroupRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // エラーメッセージを受けっとたか判定するために設定
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DeleteGroupViewModel(this._repository);

  // Viewからの命令を受けて実行(加入に成功したか失敗したかを出力)
  Future<bool> deleteGroup(
    String userId,
    String groupId
  ) async {
    _isLoading = true;

    if (groupId.isNotEmpty && userId.isNotEmpty) {  // group idとuser idが空でないとき
      try {
        await _repository.deleteGroup(
          userId: userId,
          groupId: groupId
        );
        _isLoading = false;
        return true;
      } catch (e) {
        _errorMessage = '$e';
        _isLoading = false;
        return false;
      }
    } else {

      _errorMessage = 'Please enter groupID.';
      _isLoading = false;
      return false;
    }
  }
}


class GroupListViewModel {
  final GroupRepository _repository;

  // 状態(State)を管理
  List<GroupEntity> _groups = [];
  List<GroupEntity> get groups => _groups;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // エラーメッセージを受けっとたか判定するために設定
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  GroupListViewModel(this._repository);

  // Viewからの命令を受けて実行(加入に成功したか失敗したかを出力)
  Future<void> getGroups(String userId) async {
    _isLoading = true;

    if (userId.isNotEmpty) {  // user idが空でないとき
      try {
        _groups = await _repository.getGroups(userId);
        _isLoading = false;
      } catch (e) {
        _errorMessage = '$e';
        _isLoading = false;
      }
    } else {

      _errorMessage = null;
      _isLoading = false;
      _groups = [];
    }
  }
}
