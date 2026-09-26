class Group {
  final String id;
  final String groupName;
  final String invitationCode;
  final DateTime createdAt;
  final int? role; // 所属時のユーザーの権限 (0: admin, 1: member)

  const Group({
    required this.id,
    required this.groupName,
    required this.invitationCode,
    required this.createdAt,
    this.role,
  });

  factory Group.fromJson(Map<String, dynamic> json, {int? role}) {
    return Group(
      id: json['id'] as String,
      groupName: json['group_name'] as String,
      invitationCode: json['invitation_code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      role: role ?? (json['role'] as int?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_name': groupName,
      'invitation_code': invitationCode,
      'created_at': createdAt.toIso8601String(),
      if (role != null) 'role': role,
    };
  }
}