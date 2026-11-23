class UserModel {
  final String id;
  final String email;
  final String displayName;
  final int level;
  final int totalPoints;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.level = 1,
    this.totalPoints = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      level: (json['level'] as num?)?.toInt() ?? 1,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'level': level,
      'totalPoints': totalPoints,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    int? level,
    int? totalPoints,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      level: level ?? this.level,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
