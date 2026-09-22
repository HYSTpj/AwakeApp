import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application_1/data/repositories/group_repository.dart';
import 'package:flutter_application_1/models/group.dart';
import 'package:flutter_application_1/presentation/views/group_view_model.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository mockGroupRepository;
  late GroupViewModel viewModel;

  final testGroup = Group(
    id: 'group-uuid-001',
    groupName: 'Awake Dev Team',
    invitationCode: 'WAKE99',
    createdAt: DateTime.parse('2026-09-21T10:00:00Z'),
    role: 0,
  );

  setUp(() {
    mockGroupRepository = MockGroupRepository();
    viewModel = GroupViewModel(mockGroupRepository);
  });

  group('GroupViewModel - グループ一覧読み込みテスト', () {
    test('loadGroups 成功時: 所属グループ一覧が保持されること', () async {
      when(() => mockGroupRepository.getGroups())
          .thenAnswer((_) async => [testGroup]);

      await viewModel.loadGroups();

      expect(viewModel.state.groups.length, equals(1));
      expect(viewModel.state.groups.first.groupName, equals('Awake Dev Team'));
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('loadGroups 失敗時: errorMessage に例外内容が設定されること', () async {
      when(() => mockGroupRepository.getGroups())
          .thenThrow(Exception('Failed to fetch groups'));

      await viewModel.loadGroups();

      expect(viewModel.state.groups, isEmpty);
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, contains('Failed to fetch groups'));
    });
  });

  group('GroupViewModel - グループ作成テスト', () {
    test('createGroup 成功時: groups リストに新グループが追加されること', () async {
      when(() => mockGroupRepository.createGroup('Awake Dev Team'))
          .thenAnswer((_) async => testGroup);

      final result = await viewModel.createGroup('Awake Dev Team');

      expect(result, isTrue);
      expect(viewModel.state.groups.contains(testGroup), isTrue);
      expect(viewModel.state.isLoading, isFalse);
    });
  });

  group('GroupViewModel - 招待コード参加テスト', () {
    test('joinGroupByCode 成功時: 再度グループ一覧が読み込まれること', () async {
      when(() => mockGroupRepository.joinGroupByCode('WAKE99'))
          .thenAnswer((_) async => true);
      when(() => mockGroupRepository.getGroups())
          .thenAnswer((_) async => [testGroup]);

      final result = await viewModel.joinGroupByCode('WAKE99');

      expect(result, isTrue);
      expect(viewModel.state.groups.length, equals(1));
      verify(() => mockGroupRepository.getGroups()).called(1);
    });

    test('joinGroupByCode 無効コード時: エラーメッセージが設定され false が返ること', () async {
      when(() => mockGroupRepository.joinGroupByCode('INVALID'))
          .thenAnswer((_) async => false);

      final result = await viewModel.joinGroupByCode('INVALID');

      expect(result, isFalse);
      expect(viewModel.state.errorMessage, equals('無効な招待コードです'));
    });
  });

  group('GroupViewModel - 脱退・削除テスト', () {
    test('deleteOrLeaveGroup 成功時: リストから該当グループが削除されること', () async {
      when(() => mockGroupRepository.getGroups())
          .thenAnswer((_) async => [testGroup]);
      await viewModel.loadGroups();

      when(() => mockGroupRepository.leaveOrDeleteGroup('group-uuid-001'))
          .thenAnswer((_) async {});

      final result = await viewModel.deleteOrLeaveGroup('group-uuid-001');

      expect(result, isTrue);
      expect(viewModel.state.groups, isEmpty);
      expect(viewModel.state.isLoading, isFalse);
    });
  });
}