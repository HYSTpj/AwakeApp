class RankingUser {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final int sleepPastCount;
  final int lateCount;

  const RankingUser({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.sleepPastCount,
    required this.lateCount,
  });

  factory RankingUser.fromJson(Map<String, dynamic> json) {
    return RankingUser(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatar_url'] as String?,
      sleepPastCount: json['sleep_past_count'] as int? ?? 0,
      lateCount: json['late_count'] as int? ?? 0,
    );
  }
}