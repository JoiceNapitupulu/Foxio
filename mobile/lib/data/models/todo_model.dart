import '../../domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  const TodoModel({
    required super.id,
    required super.title,
    super.description,
    super.isCompleted = false,
    super.pointsAwarded = false,
    super.deadline,
    required super.createdAt,
    required super.updatedAt,
    super.isDeleted = false,
    super.isSynced = true,
  });

  factory TodoModel.fromJson(
    Map<String, dynamic> json, {
    bool? isSyncedOverride,
  }) {
    final now = DateTime.now();
    final createdRaw = json['createdAt']?.toString();
    final updatedRaw = json['updatedAt']?.toString();
    final deadlineRaw = json['deadline']?.toString();

    return TodoModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      pointsAwarded: json['pointsAwarded'] as bool? ?? false,
      deadline: deadlineRaw != null
          ? DateTime.tryParse(deadlineRaw)?.toLocal()
          : null,
      createdAt: (createdRaw != null ? DateTime.tryParse(createdRaw) : null)
              ?.toLocal() ??
          now,
      updatedAt: (updatedRaw != null ? DateTime.tryParse(updatedRaw) : null)
              ?.toLocal() ??
          now,
      isDeleted: json['isDeleted'] as bool? ?? false,
      isSynced: isSyncedOverride ?? (json['isSynced'] as bool? ?? true),
    );
  }

  factory TodoModel.fromEntity(TodoEntity e) {
    return TodoModel(
      id: e.id,
      title: e.title,
      description: e.description,
      isCompleted: e.isCompleted,
      pointsAwarded: e.pointsAwarded,
      deadline: e.deadline,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      isDeleted: e.isDeleted,
      isSynced: e.isSynced,
    );
  }

  @override
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    bool? isCompleted,
    bool? pointsAwarded,
    DateTime? deadline,
    bool clearDeadline = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description:
          clearDescription ? null : (description ?? this.description),
      isCompleted: isCompleted ?? this.isCompleted,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'pointsAwarded': pointsAwarded,
      'deadline': deadline?.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
    };
  }
}

class CompleteTodoResponseModel {
  final TodoModel todo;
  final int pointsEarned;
  final int totalPoints;
  final int level;
  final bool leveledUp;

  const CompleteTodoResponseModel({
    required this.todo,
    required this.pointsEarned,
    required this.totalPoints,
    required this.level,
    required this.leveledUp,
  });

  factory CompleteTodoResponseModel.fromJson(Map<String, dynamic> json) {
    final todoMap = Map<String, dynamic>.from(json['todo'] as Map);
    return CompleteTodoResponseModel(
      todo: TodoModel.fromJson(todoMap, isSyncedOverride: true),
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      leveledUp: json['leveledUp'] as bool? ?? false,
    );
  }

  CompleteTodoResult toResult() {
    return CompleteTodoResult(
      todo: todo,
      pointsEarned: pointsEarned,
      totalPoints: totalPoints,
      level: level,
      leveledUp: leveledUp,
    );
  }
}
