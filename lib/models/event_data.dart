// lib/models/event_data.dart

class EventData {
  String name;           // イベント名
  String location;       // 目的地名
  double lat;           // 緯度
  double lng;           // 経度
  DateTime scheduledTime; // 集合日時
  List<String> selectedMembers; // 選択されたメンバーID

  EventData({
    required this.name,
    required this.location,
    required this.lat,
    required this.lng,
    required this.scheduledTime,
    this.selectedMembers = const [],
  });
}