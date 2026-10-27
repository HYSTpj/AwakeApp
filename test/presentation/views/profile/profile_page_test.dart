import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/presentation/viewmodels/auth_view_model.dart';
import 'package:flutter_application_1/presentation/views/profile/profile_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthViewModel authViewModel;

  final testProfile = Profile(
    id: 'user-uuid-1234',
    nickname: 'TestUser',
    avatarUrl: null,
    sleepPastCount: 0,
    lateCount: 0,
    createdAt: DateTime.parse('2026-09-21T00:00:00Z'),
    updatedAt: DateTime.parse('2026-09-21T00:00:00Z'),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authViewModel = AuthViewModel(mockAuthRepository);
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<AuthViewModel>.value(
      value: authViewModel,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ja'),
        home: const ProfilePage(),
      ),
    );
  }

  group('ProfilePage Widget Test', () {
    testWidgets('初期表示時: プロフィール情報が取得されてニックネームが表示されること', (tester) async {
      when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
      when(
        () => mockAuthRepository.getCurrentProfile(),
      ).thenAnswer((_) async => testProfile);

      await tester.pumpWidget(createWidgetUnderTest());

      // initState の postFrameCallback 処理を完了させる
      await tester.pumpAndSettle();

      expect(find.text('TestUser'), findsOneWidget);
      expect(find.text('PROFILE'), findsOneWidget);
      expect(find.text('ユーザー名変更'), findsOneWidget);
      expect(find.text('パスワード変更'), findsOneWidget);
    });

    testWidgets('Pull-to-Refresh 実行時: forceRefresh で再取得が呼ばれること', (
      tester,
    ) async {
      when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
      when(
        () => mockAuthRepository.getCurrentProfile(),
      ).thenAnswer((_) async => testProfile);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 初回表示で 1 回呼ばれていることを確認
      verify(() => mockAuthRepository.getCurrentProfile()).called(1);

      // 下スワイプで RefreshIndicator を発火
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      // 引っ張り更新で再度 getCurrentProfile が呼ばれたことを検証
      verify(() => mockAuthRepository.getCurrentProfile()).called(1);
    });

    testWidgets('エラー時: スナックバーに再試行ボタンが表示され、タップで再取得されること', (tester) async {
      when(() => mockAuthRepository.currentUserId).thenReturn(testProfile.id);
      when(
        () => mockAuthRepository.getCurrentProfile(),
      ).thenThrow(Exception('Network Error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 取得失敗の表示とスナックバーの確認
      expect(find.text('取得失敗'), findsOneWidget);
      expect(find.text('プロフィールの取得に失敗しました。時間をおいて再試行してください'), findsOneWidget);
      expect(find.text('再試行'), findsOneWidget);

      // 次回成功するようにモックを変更
      when(
        () => mockAuthRepository.getCurrentProfile(),
      ).thenAnswer((_) async => testProfile);

      // 再試行ボタンをタップ
      await tester.tap(find.text('再試行'));
      await tester.pumpAndSettle();

      // 再試行成功でニックネームが表示されること
      expect(find.text('TestUser'), findsOneWidget);
    });
  });
}
