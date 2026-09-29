class Profile {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final int sleepPastCount;
  final int lateCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.sleepPastCount,
    required this.lateCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatar_url'] as String?,
      sleepPastCount: json['sleep_past_count'] as int? ?? 0,
      lateCount: json['late_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'sleep_past_count': sleepPastCount,
      'late_count': lateCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}