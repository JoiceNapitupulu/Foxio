import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<List<TodoEntity>> getTodos();

  Future<TodoEntity> createTodo({
    required String title,
    String? description,
    DateTime? deadline,
  });

  Future<TodoEntity> updateTodo({
    required String id,
    required String title,
    String? description,
    DateTime? deadline,
  });

  Future<CompleteTodoResult> toggleComplete({
    required String id,
    required bool isCompleted,
  });

  Future<void> deleteTodo(String id);
}
