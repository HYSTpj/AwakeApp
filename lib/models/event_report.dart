class EventReport {
  // ステータス定数の定義（マジックナンバーの排除）
  static const int statusSleeping = 0;
  static const int statusAwake = 1;
  static const int statusOverslept = 2;
  static const int statusMoving = 3;
  static const int statusArrived = 4;
  static const int statusLate = 5;

  final String id;
  final String eventId;
  final String userId;
  final DateTime? plannedWakeupTime;
  final DateTime? plannedDepartureTime;
  final DateTime? actualWakeupTime;
  final DateTime? actualDepartureTime;
  final int
  status; // 0: sleeping, 1: awake, 2: overslept, 3: moving, 4: arrived, 5: late
  final String? lateReason;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final DateTime updatedAt;

  // 定数を参照するように変更
  bool get isAwake => status >= statusAwake;
  bool get isOverslept => status == statusOverslept;
  bool get isMoving => status == statusMoving;
  bool get isArrived => status == statusArrived;
  bool get isLate => status == statusLate;

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

  /// 0〜5の整数・ステータス名・数値文字列を対応する値に変換し、未知の値は0（sleeping）にする
  static int parseStatus(dynamic rawStatus) {
    if (rawStatus is int) {
      if (rawStatus >= statusSleeping && rawStatus <= statusLate) {
        return rawStatus;
      }
      return statusSleeping; // 範囲外の整数はデフォルト
    }

    if (rawStatus is String) {
      final normalized = rawStatus.trim().toLowerCase();
      switch (normalized) {
        case 'sleeping':
        case '0':
          return statusSleeping;
        case 'awake':
        case '1':
          return statusAwake;
        case 'overslept':
        case '2':
          return statusOverslept;
        case 'moving':
        case '3':
          return statusMoving;
        case 'arrived':
        case '4':
          return statusArrived;
        case 'late':
        case '5':
          return statusLate;
        default:
          return statusSleeping; // 未知の文字列はデフォルト
      }
    }

    return statusSleeping; // null または未対応型
  }

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
    } else {
      lat = (json['latitude'] as num?)?.toDouble();
      lng = (json['longitude'] as num?)?.toDouble();
    }

    final rawUpdatedAt = json['updated_at'] as String?;
    final parsedUpdatedAt = rawUpdatedAt != null
        ? DateTime.tryParse(rawUpdatedAt)
        : null;

    return EventReport(
      id: json['id'] as String? ?? '',
      eventId: json['event_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      plannedWakeupTime: json['planned_wakeup_time'] != null
          ? DateTime.tryParse(json['planned_wakeup_time'] as String)
          : null,
      plannedDepartureTime: json['planned_departure_time'] != null
          ? DateTime.tryParse(json['planned_departure_time'] as String)
          : null,
      actualWakeupTime: json['actual_wakeup_time'] != null
          ? DateTime.tryParse(json['actual_wakeup_time'] as String)
          : null,
      actualDepartureTime: json['actual_departure_time'] != null
          ? DateTime.tryParse(json['actual_departure_time'] as String)
          : null,
      status: parseStatus(json['status']),
      lateReason: json['late_reason'] as String?,
      photoUrl: json['photo_url'] as String?,
      latitude: lat,
      longitude: lng,
      // 不正データや未設定データが「最新」と誤認されないよう、Epoch にフォールバック
      updatedAt:
          parsedUpdatedAt ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
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
      'latitude': latitude,
      'longitude': longitude,
      if (latitude != null && longitude != null)
        'location': '($latitude, $longitude)',
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
