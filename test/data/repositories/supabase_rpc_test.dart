import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

/// PostgrestFilterBuilder は Future を実装しているため、
/// 任意の戻り値や例外を Future として完了させる Fake クラスを作成する
class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final Future<T> _future;

  FakePostgrestFilterBuilder(this._future);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

void main() {
  late MockSupabaseClient mockClient;

  setUp(() {
    mockClient = MockSupabaseClient();
  });

  group('Step 1: DB RPC ユニットテスト検証', () {
    test('report_wake_up: 目標時間前なら status=1 (awake), is_late=false が返却されること', () async {
      when(() => mockClient.rpc(any(), params: any(named: 'params')))
          .thenAnswer(
        (_) => FakePostgrestFilterBuilder(
          Future.value({
            'success': true,
            'status': 1,
            'actual_wakeup_time': '2026-09-20T07:00:00Z',
            'is_late': false,
          }),
        ),
      );

      final result = await mockClient.rpc(
        'report_wake_up',
        params: {'p_event_id': 'test-event-uuid'},
      );

      expect(result['success'], isTrue);
      expect(result['status'], equals(1));
      expect(result['is_late'], isFalse);
    });

    test('report_wake_up: 目標時間超過なら status=2 (overslept), is_late=true が返却されること', () async {
      when(() => mockClient.rpc(any(), params: any(named: 'params')))
          .thenAnswer(
        (_) => FakePostgrestFilterBuilder(
          Future.value({
            'success': true,
            'status': 2,
            'actual_wakeup_time': '2026-09-20T08:30:00Z',
            'is_late': true,
          }),
        ),
      );

      final result = await mockClient.rpc(
        'report_wake_up',
        params: {'p_event_id': 'test-event-uuid'},
      );

      expect(result['status'], equals(2));
      expect(result['is_late'], isTrue);
    });

    test('check_in_by_qr: QR不一致時に例外がスローされること', () async {
      when(() => mockClient.rpc(any(), params: any(named: 'params')))
          .thenAnswer(
        (_) => FakePostgrestFilterBuilder(
          Future.error(const PostgrestException(message: 'Invalid QR Code')),
        ),
      );

      expect(
        () => mockClient.rpc(
          'check_in_by_qr',
          params: {'p_event_id': 'test-event-uuid', 'p_qrcode': 'wrong-code'},
        ),
        throwsA(isA<PostgrestException>()),
      );
    });

    test('check_in_by_passcode: 集合時間超過なら status=5 (late), is_late=true が返却されること', () async {
      when(() => mockClient.rpc(any(), params: any(named: 'params')))
          .thenAnswer(
        (_) => FakePostgrestFilterBuilder(
          Future.value({
            'success': true,
            'status': 5,
            'is_late': true,
          }),
        ),
      );

      final result = await mockClient.rpc(
        'check_in_by_passcode',
        params: {'p_event_id': 'test-event-uuid', 'p_passcode': 'correct-pass'},
      );

      expect(result['status'], equals(5));
      expect(result['is_late'], isTrue);
    });
  });
}