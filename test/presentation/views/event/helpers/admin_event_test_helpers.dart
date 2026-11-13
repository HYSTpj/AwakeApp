import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/data/repositories/admin_event_repository.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/event_report.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/presentation/viewmodels/admin_event_view_model.dart';
import 'package:flutter_application_1/presentation/viewmodels/auth_view_model.dart';

class MockAdminEventRepository extends Mock implements AdminEventRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGeocodingPlatform extends GeocodingPlatform {
  @override
  Future<List<Location>> locationFromAddress(
    String address, {
    String? localeIdentifier,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      Location(
        latitude: 35.681236,
        longitude: 139.767125,
        timestamp: DateTime.now(),
      ),
    ];
  }
}

// プロフィール取得を返すAuthViewModelを生成する
AuthViewModel createMockAuthViewModel() {
  final mockAuthRepo = MockAuthRepository();
  final dummyUser = createDummyProfile(
    id: 'dummy-auth-user',
    nickname: 'TestUser',
  );
  when(() => mockAuthRepo.currentUserId).thenReturn(dummyUser.id);
  when(
    () => mockAuthRepo.getCurrentProfile(),
  ).thenAnswer((_) async => dummyUser);
  return AuthViewModel(mockAuthRepo);
}

void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GeocodingPlatform.instance = MockGeocodingPlatform();

  setUpAll(() async {
    const channel = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getAll') {
            return <String, dynamic>{};
          }
          return true;
        });

    try {
      await Supabase.initialize(
        url: 'https://dummy.supabase.co',
        publishableKey: 'dummy-anon-key-for-widget-testing',
      );
    } catch (_) {}
  });
}

/// イベント画面用のテストWidgetを構築する
Widget buildTestableWidget({
  required AdminEventViewModel viewModel,
  AuthViewModel? authViewModel,
  required Widget child,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AdminEventViewModel>.value(value: viewModel),
      ChangeNotifierProvider<AuthViewModel>.value(
        value: authViewModel ?? createMockAuthViewModel(),
      ),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

final testNow = DateTime(2026, 10, 15, 8, 30);

Profile createDummyProfile({
  String id = 'u-1',
  String nickname = 'Alice',
  String avatarUrl = '',
}) {
  return Profile(
    id: id,
    nickname: nickname,
    avatarUrl: avatarUrl,
    sleepPastCount: 0,
    lateCount: 0,
    createdAt: testNow,
    updatedAt: testNow,
  );
}

Event createDummyEvent({
  String id = 'event-1',
  String groupId = 'group-1',
  String title = '合宿集合',
  String destinationName = '名古屋駅',
  DateTime? arrivalTime,
}) {
  return Event(
    id: id,
    groupId: groupId,
    title: title,
    destinationName: destinationName,
    arrivalTime: arrivalTime ?? testNow,
    password: 'test_password',
    qrcodeId: 'qr_test_token',
    status: '0',
    createdAt: testNow,
    updatedAt: testNow,
  );
}

EventReport createDummyReport({
  String id = 'rep-1',
  String eventId = 'event-1',
  String userId = 'u-1',
  int status = 1,
}) {
  return EventReport(
    id: id,
    eventId: eventId,
    userId: userId,
    status: status,
    actualWakeupTime: DateTime(2026, 10, 15, 6, 45),
    latitude: 35.15,
    longitude: 136.92,
    lateReason: '電車遅延のため',
    updatedAt: testNow,
  );
}
