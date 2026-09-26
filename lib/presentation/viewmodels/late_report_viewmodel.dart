import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LateReportViewModel extends ChangeNotifier {
  final String reportId;
  final String eventId;
  final String userId;
  final SupabaseClient _supabase;

  final Future<void> Function(LateReportViewModel)? mockFetchLocation;
  final Future<String> Function(String eventId, String userId, XFile photo)? mockUploadPhoto;

  XFile? evidencePhoto;
  bool isUploading = false;
  String? errorMessage;
  String reasonText = '';

  String locationName = "FETCHING LOCATION...";
  double? latitude;
  double? longitude;

  // View用のユーザー名取得ゲッター（MVVM移行）
  String get currentUserName {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'anon';
    final metadataName = user.userMetadata?['nickname'] ?? user.userMetadata?['name'];
    if (metadataName != null && metadataName.toString().isNotEmpty) {
      return metadataName.toString();
    }
    return 'user_${user.id.substring(0, 4)}';
  }

  LateReportViewModel({
    required this.reportId,
    required this.eventId,
    String? userId,
    SupabaseClient? supabaseClient,
    this.mockFetchLocation,
    this.mockUploadPhoto,
  })  : _supabase = supabaseClient ?? Supabase.instance.client,
        userId = userId ?? supabaseClient?.auth.currentUser?.id ?? Supabase.instance.client.auth.currentUser?.id ?? 'unknown' {
    if (mockFetchLocation != null) {
      mockFetchLocation!(this);
    } else {
      _fetchLocation();
    }
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationName = "GPS DISABLED";
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationName = "PERMISSION DENIED";
          notifyListeners();
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      latitude = position.latitude;
      longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String city = place.locality ?? place.administrativeArea ?? '';
        String country = place.isoCountryCode ?? '';
        locationName = city.isNotEmpty ? "$city ${country.toUpperCase()}" : "LOCATION FOUND";
      } else {
        locationName = "LOCATION FETCHED";
      }
    } catch (e) {
      debugPrint("Location error: $e");
      locationName = "LOCATION ERROR";
    }
    notifyListeners();
  }

  Future<void> capturePhoto() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (pickedFile != null) {
        evidencePhoto = pickedFile;
        errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = "Failed to launch camera: $e";
      notifyListeners();
    }
  }

  void setReason(String text) {
    reasonText = text;
  }

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
      String downloadUrl;
      if (mockUploadPhoto != null) {
        downloadUrl = await mockUploadPhoto!(eventId, userId, evidencePhoto!);
      } else {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
        final storagePath = '$eventId/$fileName';

        // Web / Native 共通でバイト配列からアップロード
        final bytes = await evidencePhoto!.readAsBytes();
        await _supabase.storage.from('late-evidences').uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

        downloadUrl = _supabase.storage.from('late-evidences').getPublicUrl(storagePath);
      }

      // Supabase の event_reports テーブルを更新
      await _supabase.rpc('submit_late_report', params: {
        'p_report_id': reportId,
        'p_reason': reasonText.trim(),
        'p_photo_url': downloadUrl,
        'p_latitude': latitude,
        'p_longitude': longitude,
      });

      isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isUploading = false;
      errorMessage = "アップロードに失敗しました。詳細: $e";
      debugPrint(errorMessage);
      notifyListeners();
      return false;
    }
  }

  bool _isDisposed = false;

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
