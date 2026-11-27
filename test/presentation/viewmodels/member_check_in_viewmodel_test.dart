import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/presentation/viewmodels/member_check_in_viewmodel.dart';
import 'package:flutter_application_1/widgets/statusbutton.dart';
import '../../data/repositories/supabase_test_mocks.dart';

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  FakePostgrestFilterBuilder(this._future);

  final Future<T> _future;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const eventId = 'event-1';
  const groupId = 'group-1';

  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MemberCheckInViewModel viewModel;

  User createUser() => User(
    id: 'user-1',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: DateTime(2026, 11, 1).toIso8601String(),
  );

  void stubRpc(
    FutureOr<dynamic> Function(String function, Map<String, dynamic>? params)
    response,
  ) {
    when(() => mockClient.rpc(any(), params: any(named: 'params'))).thenAnswer((
      invocation,
    ) {
      final function = invocation.positionalArguments[0] as String;
      final params =
          invocation.namedArguments[#params] as Map<String, dynamic>?;
      return FakePostgrestFilterBuilder(
        Future<dynamic>.sync(() => response(function, params)),
      );
    });
  }

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(null);
    when(() => mockClient.from(any())).thenThrow(Exception('Not used in test'));

    viewModel = MemberCheckInViewModel(
      eventId: eventId,
      groupId: groupId,
      supabaseClient: mockClient,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('MemberCheckInViewModel', () {
    test('loadData: 未ログイン時にエラーを設定して取得を中断する', () async {
      final error = await viewModel.loadData();

      expect(error, CheckInLoadError.notLoggedIn);
      expect(viewModel.errorMessage, isNotNull);
      verifyNever(() => mockClient.rpc(any(), params: any(named: 'params')));
    });

    test('toggleWakeUp: 未参加または押下済みの場合はRPCを呼ばない', () async {
      expect(await viewModel.toggleWakeUp(), isFalse);

      viewModel
        ..isParticipant = true
        ..isWakeUpPressed = true;
      expect(await viewModel.toggleWakeUp(), isFalse);

      verifyNever(() => mockClient.rpc(any(), params: any(named: 'params')));
    });

    test('toggleWakeUp: 成功時に起床RPCを呼び、押下状態になる', () async {
      when(() => mockAuth.currentUser).thenReturn(createUser());
      stubRpc((function, _) {
        if (function == 'report_wake_up') return {'success': true};
        if (function == 'get_my_event_report') {
          return {
            'id': 'report-1',
            'status': 1,
            'actual_wakeup_time': '2026-11-01T06:00:00Z',
          };
        }
        fail('Unexpected RPC: $function');
      });
      viewModel.isParticipant = true;

      final result = await viewModel.toggleWakeUp();

      expect(result, isTrue);
      expect(viewModel.isWakeUpPressed, isTrue);
      verify(
        () => mockClient.rpc('report_wake_up', params: {'p_event_id': eventId}),
      ).called(1);
    });

    test('toggleDeparture: 未参加または押下済みの場合はRPCを呼ばない', () async {
      expect(await viewModel.toggleDeparture(), isFalse);

      viewModel
        ..isParticipant = true
        ..isDeparturePressed = true;
      expect(await viewModel.toggleDeparture(), isFalse);

      verifyNever(() => mockClient.rpc(any(), params: any(named: 'params')));
    });

    test('toggleDeparture: 成功時に出発RPCを呼び、押下状態になる', () async {
      when(() => mockAuth.currentUser).thenReturn(createUser());
      stubRpc((function, _) {
        if (function == 'report_departure') return {'success': true};
        if (function == 'get_my_event_report') {
          return {
            'id': 'report-1',
            'status': 3,
            'actual_departure_time': '2026-11-01T07:00:00Z',
          };
        }
        fail('Unexpected RPC: $function');
      });
      viewModel.isParticipant = true;

      final result = await viewModel.toggleDeparture();

      expect(result, isTrue);
      expect(viewModel.isDeparturePressed, isTrue);
      verify(
        () =>
            mockClient.rpc('report_departure', params: {'p_event_id': eventId}),
      ).called(1);
    });

    test('verifyAndCheckIn: QR検証成功時にチェックインRPCを呼びtrueを返す', () async {
      when(() => mockAuth.currentUser).thenReturn(createUser());
      stubRpc((function, _) {
        if (function == 'check_in_by_qr') return {'success': true};
        if (function == 'get_my_event_report') {
          return {'id': 'report-1', 'status': 4};
        }
        fail('Unexpected RPC: $function');
      });
      viewModel.isParticipant = true;

      final result = await viewModel.verifyAndCheckIn('qrcode', ' qr-value ');

      expect(result, isTrue);
      expect(viewModel.isCheckInPressed, isTrue);
      expect(viewModel.selectedStatus, StatusButtonType.arrived);
      verify(
        () => mockClient.rpc(
          'check_in_by_qr',
          params: {'p_event_id': eventId, 'p_qrcode': 'qr-value'},
        ),
      ).called(1);
    });

    test('verifyAndCheckIn: 検証失敗時はfalseを返しステータスを維持する', () async {
      stubRpc((function, _) {
        if (function == 'check_in_by_qr') return {'success': false};
        fail('Unexpected RPC: $function');
      });
      viewModel.isParticipant = true;
      const originalStatus = StatusButtonType.awake;
      viewModel.selectedStatus = originalStatus;

      final result = await viewModel.verifyAndCheckIn('qrcode', 'invalid');

      expect(result, isFalse);
      expect(viewModel.isCheckInPressed, isFalse);
      expect(viewModel.selectedStatus, originalStatus);
      expect(viewModel.errorMessage, isNotNull);
    });
  });
}
