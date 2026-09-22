class Event {
  final String id;
  final String groupId;
  final String title;
  final String destinationName;
  final double? latitude;
  final double? longitude;
  final String qrcodeId;
  final String password;
  final DateTime arrivalTime;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.groupId,
    required this.title,
    required this.destinationName,
    this.latitude,
    this.longitude,
    required this.qrcodeId,
    required this.password,
    required this.arrivalTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lng;
    final loc = json['location'];
    if (loc is Map<String, dynamic>) {
      lat = (loc['x'] as num?)?.toDouble();
      lng = (loc['y'] as num?)?.toDouble();
    } else if (loc is String) {
      // "(lat, lng)" 形式の文字列パース対応
      final clean = loc.replaceAll('(', '').replaceAll(')', '');
      final parts = clean.split(',');
      if (parts.length == 2) {
        lat = double.tryParse(parts[0].trim());
        lng = double.tryParse(parts[1].trim());
      }
    }

    return Event(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      title: json['title'] as String,
      destinationName: json['destination_name'] as String,
      latitude: lat,
      longitude: lng,
      qrcodeId: json['qrcode_id'] as String,
      password: json['password'] as String,
      arrivalTime: DateTime.parse(json['arrival_time'] as String),
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse((json['update_at'] ?? json['updated_at']) as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'title': title,
      'destination_name': destinationName,
      'qrcode_id': qrcodeId,
      'password': password,
      'arrival_time': arrivalTime.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'update_at': updatedAt.toIso8601String(),
    };
  }
}