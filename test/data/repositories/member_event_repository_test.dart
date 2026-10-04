import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/data/repositories/member_event_repository.dart';

import 'supabase_test_mocks.dart';

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late SupabaseMemberEventRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    // 未認証状態（currentUserがnull）をデフォルトにする。
    when(() => mockAuth.currentUser).thenReturn(null);
    repository = SupabaseMemberEventRepository(mockClient);
  });

  group('SupabaseMemberEventRepository 認証ガード', () {
    test(
      '未認証の場合、setPlannedTimes()はAuthExceptionを投げ、DBへのクエリは発行しない',
      () async {
        await expectLater(
          () => repository.setPlannedTimes(
            eventId: 'event-1',
            wakeupTime: DateTime(2026, 5, 14, 6, 30),
            departureTime: DateTime(2026, 5, 14, 7, 15),
          ),
          throwsA(isA<AuthException>()),
        );

        // 認証チェックで早期returnするため、.from()は一度も呼ばれない。
        verifyNever(() => mockClient.from(any()));
      },
    );

    test(
      '未認証の場合、submitLateReport()はAuthExceptionを投げ、DBへのクエリは発行しない',
      () async {
        expect(
          () => repository.submitLateReport(
            eventId: 'event-1',
            reason: '電車遅延',
          ),
          throwsA(isA<AuthException>()),
        );

        // 認証チェックで早期returnするため、rpc()は一度も呼ばれない。
        verifyNever(() => mockClient.rpc(any(), params: any(named: 'params')));
      },
    );

    test('未認証の場合、getMyReport()は例外を投げずnullを返す', () async {
      final result = await repository.getMyReport('event-1');

      expect(result, isNull);
      // 認証チェックで早期returnするため、.from()は一度も呼ばれない。
      verifyNever(() => mockClient.from(any()));
    });
  });
}
