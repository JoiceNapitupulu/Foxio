class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? avatarData;
  final int level;
  final int totalPoints;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarData,
    this.level = 1,
    this.totalPoints = 0,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarData,
    bool clearAvatar = false,
    int? level,
    int? totalPoints,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarData: clearAvatar ? null : (avatarData ?? this.avatarData),
      level: level ?? this.level,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
