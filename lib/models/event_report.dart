class EventReport {
  final String id;
  final String eventId;
  final String userId;
  final DateTime? plannedWakeupTime;
  final DateTime? plannedDepartureTime;
  final DateTime? actualWakeupTime;
  final DateTime? actualDepartureTime;
  final int status; // 0: sleeping, 1: awake, 2: overslept, 3: moving, 4: arrived, 5: late
  final String? lateReason;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final DateTime updatedAt;

  // UI表示用ヘルパープロパティ
  bool get isAwake => status >= 1;
  bool get isOverslept => status == 2;
  bool get isMoving => status == 3;
  bool get isArrived => status == 4;
  bool get isLate => status == 5;

  const EventReport({
    required this.id,
    required this.eventId,
    required this.userId,
    this.plannedWakeupTime,
    this.plannedDepartureTime,
    this.actualWakeupTime,
    this.actualDepartureTime,
    required this.status,
    this.lateReason,
    this.photoUrl,
    this.latitude,
    this.longitude,
    required this.updatedAt,
  });

  factory EventReport.fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lng;
    final loc = json['location'];
    if (loc is Map<String, dynamic>) {
      lat = (loc['x'] as num?)?.toDouble();
      lng = (loc['y'] as num?)?.toDouble();
    } else if (loc is String) {
      final clean = loc.replaceAll('(', '').replaceAll(')', '');
      final parts = clean.split(',');
      if (parts.length == 2) {
        lat = double.tryParse(parts[0].trim());
        lng = double.tryParse(parts[1].trim());
      }
    }

    return EventReport(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      plannedWakeupTime: json['planned_wakeup_time'] != null
          ? DateTime.parse(json['planned_wakeup_time'] as String)
          : null,
      plannedDepartureTime: json['planned_departure_time'] != null
          ? DateTime.parse(json['planned_departure_time'] as String)
          : null,
      actualWakeupTime: json['actual_wakeup_time'] != null
          ? DateTime.parse(json['actual_wakeup_time'] as String)
          : null,
      actualDepartureTime: json['actual_departure_time'] != null
          ? DateTime.parse(json['actual_departure_time'] as String)
          : null,
      status: json['status'] as int? ?? 0,
      lateReason: json['late_reason'] as String?,
      photoUrl: json['photo_url'] as String?,
      latitude: lat,
      longitude: lng,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'planned_wakeup_time': plannedWakeupTime?.toIso8601String(),
      'planned_departure_time': plannedDepartureTime?.toIso8601String(),
      'actual_wakeup_time': actualWakeupTime?.toIso8601String(),
      'actual_departure_time': actualDepartureTime?.toIso8601String(),
      'status': status,
      'late_reason': lateReason,
      'photo_url': photoUrl,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}