import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awake_app/viewmodels/late_report_viewmodel.dart';
import 'package:awake_app/data/event_repository.dart';

// Fake Repository to prevent actual Firestore calls
class FakeEventRepository extends EventRepository {
  bool updateLateReportCalled = false;

  @override
  Future<void> updateLateReport(
    String reportId,
    String reason,
    String photoUrl,
    GeoPoint location,
  ) async {
    updateLateReportCalled = true;
  }
}

void main() {
  group('LateReportViewModel Validation Tests', () {
    late LateReportViewModel viewModel;
    late FakeEventRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeEventRepository();
      viewModel = LateReportViewModel(
        reportId: 'test_report_id',
        eventId: 'test_event_id',
        userId: 'test_user_id',
        eventRepository: fakeRepo,
        mockFetchLocation: (vm) async {
          // Do nothing, so latitude/longitude remain null by default
        },
        mockUploadPhoto: (eventId, userId, photo) async {
          return 'https://example.com/dummy.jpg';
        },
      );
    });

    test('写真未選択時、エラーになること', () async {
      // evidencePhoto is null by default
      viewModel.reasonText = '遅れました';
      viewModel.latitude = 35.0;
      viewModel.longitude = 139.0;

      final result = await viewModel.submitReport();

      expect(result, isFalse);
      expect(viewModel.errorMessage, 'CAPTURE EVIDENCE (写真) の撮影が必須です。');
      expect(fakeRepo.updateLateReportCalled, isFalse);
    });

    test('理由未入力時、エラーになること', () async {
      viewModel.evidencePhoto = XFile('dummy_path');
      viewModel.reasonText = '   '; // Empty or whitespace
      viewModel.latitude = 35.0;
      viewModel.longitude = 139.0;

      final result = await viewModel.submitReport();

      expect(result, isFalse);
      expect(viewModel.errorMessage, '遅刻の理由を入力してください。');
      expect(fakeRepo.updateLateReportCalled, isFalse);
    });

    test('位置情報未取得時、エラーになること', () async {
      viewModel.evidencePhoto = XFile('dummy_path');
      viewModel.reasonText = '遅れました';
      // latitude, longitude are null

      final result = await viewModel.submitReport();

      expect(result, isFalse);
      expect(viewModel.errorMessage, '位置情報が取得できていません。GPSの設定を確認してください。');
      expect(fakeRepo.updateLateReportCalled, isFalse);
    });

    test('すべて入力済みの場合はアップロードが開始され、Firestoreが更新されること', () async {
      viewModel.evidencePhoto = XFile('dummy_path');
      viewModel.reasonText = '遅れました';
      viewModel.latitude = 35.0;
      viewModel.longitude = 139.0;

      final result = await viewModel.submitReport();

      expect(result, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(fakeRepo.updateLateReportCalled, isTrue);
    });
  });
}
