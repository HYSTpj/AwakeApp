import 'package:flutter/foundation.dart';
// Use a conditional import for platform File access so this file stays web-safe.
import '../utils/platform_file_io.dart'
  if (dart.library.html) '../utils/platform_file_stub.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/event_repository.dart';

class LateReportViewModel extends ChangeNotifier {
  final String reportId;
  final String eventId;
  final String userId;
  final EventRepository _eventRepository;

  XFile? evidencePhoto;
  bool isUploading = false;
  String? errorMessage;
  String reasonText = '';

  String locationName = "FETCHING LOCATION...";
  double? latitude;
  double? longitude;

  // View用のユーザー名取得ゲッター（MVVM移行）
  String get currentUserName {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'anon';
    return user.displayName ?? 'user_${user.uid.substring(0, 4)}';
  }

  LateReportViewModel({
    required this.reportId,
    required this.eventId,
    String? userId,
    EventRepository? eventRepository,
  })  : userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
        _eventRepository = eventRepository ?? EventRepository() {
    _fetchLocation();
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
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('late_reports')
          .child(eventId)
          .child(fileName);

      if (kIsWeb) {
        final bytes = await evidencePhoto!.readAsBytes();
        await ref.putData(bytes);
      } else {
        final file = platformFile(evidencePhoto!.path);
        await ref.putFile(file);
      }
      final downloadUrl = await ref.getDownloadURL();

      await _eventRepository.updateLateReport(
        reportId,
        reasonText.trim(),
        downloadUrl,
        GeoPoint(latitude!, longitude!),
      );

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
