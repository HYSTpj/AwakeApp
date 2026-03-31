import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/event_repository.dart';

class LateReportViewModel extends ChangeNotifier {
  final String reportId;
  final String eventId;
  final String userId;
  final EventRepository _eventRepository;

  File? evidencePhoto;
  bool isUploading = false;
  String? errorMessage;
  String reasonText = '';

  String locationName = "FETCHING LOCATION...";
  double? latitude;
  double? longitude;

  LateReportViewModel({
    required this.reportId,
    required this.eventId,
    required this.userId,
    EventRepository? eventRepository,
  }) : _eventRepository = eventRepository ?? EventRepository() {
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
        // "東京都, JP" のような都市情報に整形
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
      // カメラを起動して写真を撮影 (品質を落としてデータ量を節約)
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera, 
        imageQuality: 70,
        maxWidth: 1024,
      );
      
      if (pickedFile != null) {
        evidencePhoto = File(pickedFile.path);
        errorMessage = null; // エラーメッセージをクリア
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
      // 1. Firebase Storage へ画像をアップロード
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('late_reports')
          .child(eventId)
          .child(fileName);
          
      // アップロードの実行
      await ref.putFile(evidencePhoto!);
      
      // ダウンロードURL（表示用の公開URL）を取得
      final downloadUrl = await ref.getDownloadURL();

      // 2. Repository 経由で Firestore (event_reports) のデータを上書きして status を 5 にする
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
}
