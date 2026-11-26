import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarData,
    super.level = 1,
    super.totalPoints = 0,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      avatarData: entity.avatarData,
      level: entity.level,
      totalPoints: entity.totalPoints,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawAvatar = json['avatarData']?.toString().trim();
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      avatarData: (rawAvatar == null || rawAvatar.isEmpty) ? null : rawAvatar,
      level: (json['level'] as num?)?.toInt() ?? 1,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson({bool includeAvatar = true}) {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      if (includeAvatar && avatarData != null) 'avatarData': avatarData,
      'level': level,
      'totalPoints': totalPoints,
    };
  }
}
