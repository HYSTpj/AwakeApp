import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

final testProfile = Profile(
  id: 'user-uuid-1234',
  nickname: 'TestUser',
  avatarUrl: null,
  sleepPastCount: 0,
  lateCount: 0,
  createdAt: DateTime.parse('2026-09-21T00:00:00Z'),
  updatedAt: DateTime.parse('2026-09-21T00:00:00Z'),
);

final otherProfile = Profile(
  id: 'user-uuid-5678',
  nickname: 'OtherUser',
  avatarUrl: null,
  sleepPastCount: 0,
  lateCount: 0,
  createdAt: DateTime.parse('2026-09-21T00:00:00Z'),
  updatedAt: DateTime.parse('2026-09-21T00:00:00Z'),
);
