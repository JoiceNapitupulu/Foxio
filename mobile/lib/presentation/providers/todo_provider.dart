import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import 'auth_provider.dart';

enum TodoFilter { all, active, completed }

enum MascotMood { idle, excited, levelUp }

class TodoState {
  final List<TodoEntity> todos;
  final TodoFilter filter;
  final bool isLoading;
  final MascotMood mascotMood;
  final String? rewardBannerText;
  final String? errorMessage;

  const TodoState({
    this.todos = const [],
    this.filter = TodoFilter.all,
    this.isLoading = false,
    this.mascotMood = MascotMood.idle,
    this.rewardBannerText,
    this.errorMessage,
  });

  List<TodoEntity> get filteredTodos {
    switch (filter) {
      case TodoFilter.active:
        return todos.where((t) => !t.isCompleted).toList();
      case TodoFilter.completed:
        return todos.where((t) => t.isCompleted).toList();
      case TodoFilter.all:
        return todos;
    }
  }

  int get totalCount => todos.length;

  int get completedCount => todos.where((t) => t.isCompleted).length;

  double get progress => totalCount == 0 ? 0.0 : completedCount / totalCount;

  int get unsyncedCount => todos.where((t) => !t.isSynced).length;

  TodoState copyWith({
    List<TodoEntity>? todos,
    TodoFilter? filter,
    bool? isLoading,
    MascotMood? mascotMood,
    String? rewardBannerText,
    bool clearRewardBanner = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      mascotMood: mascotMood ?? this.mascotMood,
      rewardBannerText: clearRewardBanner
          ? null
          : (rewardBannerText ?? this.rewardBannerText),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TodoNotifier extends Notifier<TodoState> {
  Timer? _moodResetTimer;

  @override
  TodoState build() {
    ref.onDispose(() {
      _moodResetTimer?.cancel();
    });

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        loadTodos();
      } else if (next.status == AuthStatus.unauthenticated) {
        _moodResetTimer?.cancel();
        state = const TodoState();
      }
    });

    if (ref.read(authProvider).status == AuthStatus.authenticated) {
      Future.microtask(loadTodos);
    }

    return const TodoState();
  }

  TodoRepository get _repo => ref.read(todoRepositoryProvider);

  List<TodoEntity> _sorted(List<TodoEntity> items) {
    final copy = List<TodoEntity>.from(items);
    copy.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.deadline != null && b.deadline != null) {
        final cmp = a.deadline!.compareTo(b.deadline!);
        if (cmp != 0) return cmp;
      } else if (a.deadline != null && b.deadline == null) {
        return -1;
      } else if (a.deadline == null && b.deadline != null) {
        return 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return copy;
  }

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repo.getTodos();
      state = state.copyWith(todos: _sorted(list), isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: DioClient.parseErrorMessage(e),
      );
    }
  }

  void setFilter(TodoFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<bool> addTodo({
    required String title,
    String? description,
    DateTime? deadline,
  }) async {
    state = state.copyWith(clearError: true);
    try {
      final created = await _repo.createTodo(
        title: title,
        description: description,
        deadline: deadline,
      );
      state = state.copyWith(todos: _sorted([...state.todos, created]));
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: DioClient.parseErrorMessage(e));
      return false;
    }
  }

  Future<bool> editTodo({
    required String id,
    required String title,
    String? description,
    DateTime? deadline,
  }) async {
    state = state.copyWith(clearError: true);
    try {
      final updated = await _repo.updateTodo(
        id: id,
        title: title,
        description: description,
        deadline: deadline,
      );
      final updatedList =
          state.todos.map((t) => t.id == id ? updated : t).toList();
      state = state.copyWith(todos: _sorted(updatedList));
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: DioClient.parseErrorMessage(e));
      return false;
    }
  }

  Future<void> toggleComplete(TodoEntity todo) async {
    state = state.copyWith(clearError: true);
    try {
      final result = await _repo.toggleComplete(
        id: todo.id,
        isCompleted: !todo.isCompleted,
      );

      final updatedList =
          state.todos.map((t) => t.id == todo.id ? result.todo : t).toList();
      state = state.copyWith(todos: _sorted(updatedList));

      ref.read(authProvider.notifier).updatePointsAndLevel(
            totalPoints: result.totalPoints,
            level: result.level,
          );

      if (result.todo.isCompleted) {
        final nextMood =
            result.leveledUp ? MascotMood.levelUp : MascotMood.excited;
        final bannerText = result.leveledUp
            ? 'Level Up ke Lv.${result.level}! +${result.pointsEarned} pts'
            : (result.pointsEarned > 0
                ? 'Yay! Task selesai (+${result.pointsEarned} pts)'
                : 'Task selesai!');

        state = state.copyWith(
          mascotMood: nextMood,
          rewardBannerText: bannerText,
        );

        _moodResetTimer?.cancel();
        _moodResetTimer = Timer(const Duration(seconds: 4), () {
          state = state.copyWith(
            mascotMood: MascotMood.idle,
            clearRewardBanner: true,
          );
        });
      }
    } catch (e) {
      state = state.copyWith(errorMessage: DioClient.parseErrorMessage(e));
    }
  }

  Future<void> deleteTodo(String id) async {
    final previous = state.todos;
    state = state.copyWith(
      todos: state.todos.where((t) => t.id != id).toList(),
      clearError: true,
    );
    try {
      await _repo.deleteTodo(id);
    } catch (e) {
      state = state.copyWith(
        todos: previous,
        errorMessage: DioClient.parseErrorMessage(e),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final todoProvider = NotifierProvider<TodoNotifier, TodoState>(
  TodoNotifier.new,
);
