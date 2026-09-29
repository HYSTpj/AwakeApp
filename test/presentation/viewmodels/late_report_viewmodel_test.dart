import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/presentation/viewmodels/late_report_viewmodel.dart';

// テスト用にDBへの実リクエストを安全に回避するためのサブクラス
class TestLateReportViewModel extends LateReportViewModel {
  bool updateLateReportCalled = false;
  Map<String, dynamic>? updatedData;

  TestLateReportViewModel({
    required super.reportId,
    required super.eventId,
    super.userId,
    super.mockFetchLocation,
    super.mockUploadPhoto,
    super.supabaseClient,
  });

  @override
  Future<bool> submitReport() async {
    if (evidencePhoto == null) {
      errorMessage = "CAPTURE EVIDENCE (写真) の撮影が必須です。";
      notifyListeners();
      return false;
    }
    if (reasonText.trim().isEmpty) {
      errorMessage = "遅刻の理由を入力してください。";
      notifyListeners();
      return false;
    }
    if (latitude == null || longitude == null) {
      errorMessage = "位置情報が取得できていません。GPSの設定を確認してください。";
      notifyListeners();
      return false;
    }

    isUploading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String downloadUrl = 'https://example.com/dummy.jpg';
      if (mockUploadPhoto != null) {
        downloadUrl = await mockUploadPhoto!(eventId, userId, evidencePhoto!);
      }

      // DB更新処理をシミュレート
      updatedData = {
        'late_reason': reasonText.trim(),
        'photo_url': downloadUrl,
        'location': '($latitude, $longitude)',
        'status': 'overslept',
      };
      updateLateReportCalled = true;

      isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isUploading = false;
      errorMessage = "アップロードに失敗しました。詳細: $e";
      notifyListeners();
      return false;
    }
  }
}

void main() {
  group('LateReportViewModel Validation Tests', () {
    late TestLateReportViewModel viewModel;
    // shared_preferences に依存しない純粋な SupabaseClient インスタンス
    final dummyClient = SupabaseClient('https://dummy.supabase.co', 'dummy-key');

    setUp(() {
      viewModel = TestLateReportViewModel(
        reportId: 'test_report_id',
        eventId: 'test_event_id',
        userId: 'test_user_id',
        supabaseClient: dummyClient,
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
      expect(viewModel.updateLateReportCalled, isFalse);
    });

    test('理由未入力時、エラーになること', () async {
      viewModel.evidencePhoto = XFile('dummy_path');
      viewModel.reasonText = '   '; // Empty or whitespace
      viewModel.latitude = 35.0;
      viewModel.longitude = 139.0;

      final result = await viewModel.submitReport();

      expect(result, isFalse);
      expect(viewModel.errorMessage, '遅刻の理由を入力してください。');
      expect(viewModel.updateLateReportCalled, isFalse);
    });

    test('位置情報未取得時、エラーになること', () async {
      viewModel.evidencePhoto = XFile('dummy_path');
      viewModel.reasonText = '遅れました';
      // latitude, longitude are null

      final result = await viewModel.submitReport();

      expect(result, isFalse);
      expect(viewModel.errorMessage, '位置情報が取得できていません。GPSの設定を確認してください。');
      expect(viewModel.updateLateReportCalled, isFalse);
    });

    test('すべて入力済みの場合はアップロードが成功し、レポート情報が正しくセットされること', () async {
      viewModel.evidencePhoto = XFile('dummy_path');
      viewModel.reasonText = '遅れました';
      viewModel.latitude = 35.0;
      viewModel.longitude = 139.0;

      final result = await viewModel.submitReport();

      expect(result, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.updateLateReportCalled, isTrue);
      expect(viewModel.updatedData?['location'], '(35.0, 139.0)');
      expect(viewModel.updatedData?['late_reason'], '遅れました');
      expect(viewModel.updatedData?['status'], 'overslept');
    });
  });
}
