class TodoEntity {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool pointsAwarded;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;

  const TodoEntity({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.pointsAwarded = false,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isSynced = true,
  });

  TodoEntity copyWith({
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
    return TodoEntity(
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
}

class CompleteTodoResult {
  final TodoEntity todo;
  final int pointsEarned;
  final int totalPoints;
  final int level;
  final bool leveledUp;

  const CompleteTodoResult({
    required this.todo,
    required this.pointsEarned,
    required this.totalPoints,
    required this.level,
    required this.leveledUp,
  });
}
