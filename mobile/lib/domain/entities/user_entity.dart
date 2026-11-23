class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final int level;
  final int totalPoints;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.level = 1,
    this.totalPoints = 0,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    int? level,
    int? totalPoints,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      level: level ?? this.level,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
