import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/ranking_repository.dart';
import '../../models/ranking_user.dart';

class RankingState {
  final List<RankingUser> rankings;
  final String eventStatus;
  final bool isCompleted;
  final bool isLoading;
  final String? errorMessage;

  const RankingState({
    this.rankings = const [],
    this.eventStatus = 'active',
    this.isCompleted = false,
    this.isLoading = false,
    this.errorMessage,
  });

  RankingState copyWith({
    List<RankingUser>? rankings,
    String? eventStatus,
    bool? isCompleted,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RankingState(
      rankings: rankings ?? this.rankings,
      eventStatus: eventStatus ?? this.eventStatus,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RankingViewModel extends ChangeNotifier {
  final RankingRepository _repository;
  StreamSubscription<String>? _statusSubscription;
  int _rankingRequestGeneration = 0;

  RankingState _state = const RankingState();

  RankingViewModel(this._repository);

  RankingState get state => _state;

  /// 管理者または他メンバーによるイベント終了をリアルタイムに検知
  void listenEventStatus(String eventId) {
    _statusSubscription?.cancel();
    _statusSubscription = _repository.watchEventStatus(eventId).listen(
      (status) {
        final completed = (status == 'completed');
        _state = _state.copyWith(
          eventStatus: status,
          isCompleted: completed,
        );
        notifyListeners();
      },
      onError: (err) {
        _state = _state.copyWith(errorMessage: err.toString());
        notifyListeners();
      },
    );
  }

  /// 管理者によるイベント終了の確定処理
  Future<void> endEvent(String eventId) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _repository.completeEvent(eventId);
      _state = _state.copyWith(isLoading: false, isCompleted: true, eventStatus: 'completed');
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
    }
  }

  /// グループ内イベントのランキングデータを取得
  Future<void> loadRankings(String groupId) async {
    final requestGeneration = ++_rankingRequestGeneration;
    _state = _state.copyWith(
      rankings: const [],
      isLoading: true,
      clearError: true,
    );
    notifyListeners();

    try {
      final rankings = await _repository.getGroupRankings(groupId);
      if (requestGeneration != _rankingRequestGeneration) return;

      _state = _state.copyWith(rankings: rankings, isLoading: false);
      notifyListeners();
    } catch (e) {
      if (requestGeneration != _rankingRequestGeneration) return;

      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}
