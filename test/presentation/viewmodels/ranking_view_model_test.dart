import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application_1/data/repositories/ranking_repository.dart';
import 'package:flutter_application_1/models/ranking_user.dart';
import 'package:flutter_application_1/presentation/viewmodels/ranking_view_model.dart';

class MockRankingRepository extends Mock implements RankingRepository {}

void main() {
  late MockRankingRepository mockRepository;
  late RankingViewModel viewModel;
  late StreamController<String> statusController;

  final user1 = RankingUser(
    id: 'user-001',
    nickname: 'LateKing',
    streak: 1,
    totalDelayMinutes: 120,
    avgDelayMinutes: 60,
  );

  final user2 = RankingUser(
    id: 'user-002',
    nickname: 'SleepKing',
    streak: 8,
    totalDelayMinutes: 30,
    avgDelayMinutes: 15,
  );

  setUp(() {
    mockRepository = MockRankingRepository();
    statusController = StreamController<String>.broadcast();
    when(() => mockRepository.watchEventStatus('event-001'))
        .thenAnswer((_) => statusController.stream);

    viewModel = RankingViewModel(mockRepository);
  });

  tearDown(() {
    statusController.close();
    viewModel.dispose();
  });

  group('RankingViewModel - イベントステータス監視テスト', () {
    test('status が completed に変わった際に isCompleted が true になること', () async {
      viewModel.listenEventStatus('event-001');

      statusController.add('active');
      await pumpEventQueue();
      expect(viewModel.state.isCompleted, isFalse);

      statusController.add('completed');
      await pumpEventQueue();
      expect(viewModel.state.isCompleted, isTrue);
      expect(viewModel.state.eventStatus, equals('completed'));
    });
  });

  group('RankingViewModel - イベント終了操作テスト', () {
    test('endEvent 成功時: isCompleted が true に設定されること', () async {
      when(() => mockRepository.completeEvent('event-001'))
          .thenAnswer((_) async {});

      await viewModel.endEvent('event-001');

      expect(viewModel.state.isCompleted, isTrue);
      expect(viewModel.state.eventStatus, equals('completed'));
      expect(viewModel.state.isLoading, isFalse);
    });

    test('endEvent 失敗時: errorMessage に例外内容が設定されること', () async {
      when(() => mockRepository.completeEvent('event-001'))
          .thenThrow(Exception('Update error'));

      await viewModel.endEvent('event-001');

      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, contains('Update error'));
    });
  });

  group('RankingViewModel - ランキング取得テスト', () {
    test('loadRankings 成功時: グループランキングが格納されること', () async {
      when(
        () => mockRepository.getGroupRankings('group-001'),
      ).thenAnswer((_) async => [user2, user1]);

      await viewModel.loadRankings('group-001');

      expect(viewModel.state.rankings.first.nickname, equals('SleepKing'));
      expect(viewModel.state.rankings, hasLength(2));
      expect(viewModel.state.isLoading, isFalse);
    });

    test('新しいグループの結果後に古い取得が完了してもランキングを上書きしないこと', () async {
      final oldRequest = Completer<List<RankingUser>>();
      final newRequest = Completer<List<RankingUser>>();
      when(
        () => mockRepository.getGroupRankings('group-old'),
      ).thenAnswer((_) => oldRequest.future);
      when(
        () => mockRepository.getGroupRankings('group-new'),
      ).thenAnswer((_) => newRequest.future);

      final oldLoad = viewModel.loadRankings('group-old');
      final newLoad = viewModel.loadRankings('group-new');

      newRequest.complete([user2]);
      await newLoad;
      oldRequest.complete([user1]);
      await oldLoad;

      expect(viewModel.state.rankings.map((user) => user.id), ['user-002']);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('古いグループの取得エラーが新しい結果を上書きしないこと', () async {
      final oldRequest = Completer<List<RankingUser>>();
      final newRequest = Completer<List<RankingUser>>();
      when(
        () => mockRepository.getGroupRankings('group-old'),
      ).thenAnswer((_) => oldRequest.future);
      when(
        () => mockRepository.getGroupRankings('group-new'),
      ).thenAnswer((_) => newRequest.future);

      final oldLoad = viewModel.loadRankings('group-old');
      final newLoad = viewModel.loadRankings('group-new');

      newRequest.complete([user2]);
      await newLoad;
      oldRequest.completeError(Exception('stale request error'));
      await oldLoad;

      expect(viewModel.state.rankings.map((user) => user.id), ['user-002']);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, isNull);
    });
  });
}
