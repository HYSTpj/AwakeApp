import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/event_repository.dart';

class CreateEventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;

  DateTime scheduledTime = DateTime.now();
  LatLng selectedLocation = const LatLng(35.136405122360785, 136.97564747897678);
  Set<Marker> markers = {};
  bool isLoading = false;

  CreateEventViewModel({EventRepository? eventRepository})
      : _eventRepository = eventRepository ?? EventRepository();

  // 時刻表示文字列
  String get timeLabel {
    final h = scheduledTime.hour % 12 == 0 ? 12 : scheduledTime.hour % 12;
    final m = scheduledTime.minute.toString().padLeft(2, '0');
    final period = scheduledTime.hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')} : $m $period';
  }

  // 日付表示文字列
  String get dateLabel {
    final month = scheduledTime.month.toString().padLeft(2, '0');
    final day = scheduledTime.day.toString().padLeft(2, '0');
    return '$month / $day / ${scheduledTime.year}';
  }

  // 時刻の更新
  void updateTime(TimeOfDay picked) {
    scheduledTime = DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      picked.hour,
      picked.minute,
    );
    notifyListeners();
  }

  // 日付の更新
  void updateDate(DateTime picked) {
    scheduledTime = DateTime(
      picked.year,
      picked.month,
      picked.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    notifyListeners();
  }

  // 場所の検索とマップ位置の更新
  Future<void> searchLocation(String address) async {
    if (address.isEmpty) return;
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final target = LatLng(locations.first.latitude, locations.first.longitude);
        selectedLocation = target;
        markers = {
          Marker(markerId: const MarkerId('selected_location'), position: target),
        };
        notifyListeners();
      }
    } catch (e) {
      debugPrint('検索エラー: $e');
    }
  }

  // イベントをFirestoreに保存し、生成されたeventIdを返す
  Future<String?> createEvent({
    required String groupId,
    required String title,
    required String destinationName,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      return await _eventRepository.setEvent(
        groupId: groupId,
        title: title,
        destinationName: destinationName,
        location: '${selectedLocation.latitude},${selectedLocation.longitude}',
        qrcodeId: 'dummy_qr',
        password: 'default_password',
        arrivalTime: scheduledTime.toIso8601String(),
        status: 'planning',
      );
    } catch (e) {
      debugPrint('イベント作成エラー: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
