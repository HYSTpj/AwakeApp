import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application_1/group/domain/group_entity.dart';
import 'package:flutter_application_1/group/view_model/group_view_model.dart';

// GroupRepositoryは lib/group/domain/group_entity.dart で定義された
// インターフェースなので、Mockでそのまま差し替えられる（DI追加不要のお手本）。
class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  group('CreateGroupViewModel', () {
    late MockGroupRepository mockRepository;
    late CreateGroupViewModel viewModel;

    setUp(() {
      mockRepository = MockGroupRepository();
      viewModel = CreateGroupViewModel(mockRepository);
    });

    test('グループ名が空の場合、エラーになりRepositoryは呼ばれない', () async {
      final result = await viewModel.createGroup('user-1', '   ');

      expect(result, isFalse);
      expect(viewModel.errorMessage, 'Please enter a new group name.');
      verifyZeroInteractions(mockRepository);
    });

    test('同名のグループが既に存在する場合、エラーになりsetGroupは呼ばれない', () async {
      when(() => mockRepository.isGroupNameExists('Team A'))
          .thenAnswer((_) async => true);

      final result = await viewModel.createGroup('user-1', 'Team A');

      expect(result, isFalse);
      expect(viewModel.errorMessage, 'This group name is already taken.');
      verifyNever(
        () => mockRepository.setGroup(userId: any(named: 'userId'), groupName: any(named: 'groupName')),
      );
    });

    test('正常な入力の場合、setGroupが呼ばれtrueを返す', () async {
      when(() => mockRepository.isGroupNameExists('Team A'))
          .thenAnswer((_) async => false);
      when(() => mockRepository.setGroup(userId: 'user-1', groupName: 'Team A'))
          .thenAnswer((_) async => 'group-id-1');

      final result = await viewModel.createGroup('user-1', 'Team A');

      expect(result, isTrue);
      expect(viewModel.errorMessage, isNull);
      verify(() => mockRepository.setGroup(userId: 'user-1', groupName: 'Team A')).called(1);
    });
  });
}
