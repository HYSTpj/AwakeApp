class RankingUser {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final int streak;
  final int totalDelayMinutes;
  final int avgDelayMinutes;

  const RankingUser({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.streak,
    required this.totalDelayMinutes,
    required this.avgDelayMinutes,
  });

  factory RankingUser.fromJson(Map<String, dynamic> json) {
    return RankingUser(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      avatarUrl: json['avatar_url'] as String?,
      streak: json['streak'] as int? ?? 0,
      totalDelayMinutes: json['total_delay_minutes'] as int? ?? 0,
      avgDelayMinutes: json['avg_delay_minutes'] as int? ?? 0,
    );
  }
}
