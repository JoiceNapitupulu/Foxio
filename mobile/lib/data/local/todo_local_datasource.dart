import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';
import 'local_storage_service.dart';

class TodoLocalDataSource {
  final LocalStorageService _storage;

  TodoLocalDataSource(this._storage);

  Box get _box => _storage.todosBox;

  List<TodoModel> getActiveTodos() {
    final items = <TodoModel>[];
    for (final raw in _box.values) {
      if (raw is Map) {
        final todo = TodoModel.fromJson(Map<String, dynamic>.from(raw));
        if (!todo.isDeleted) {
          items.add(todo);
        }
      }
    }

    // Match backend sort: incomplete first, nearest deadline asc (nulls last), newest createdAt desc
    items.sort((a, b) {
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

    return items;
  }

  TodoModel? getById(String id) {
    final raw = _box.get(id);
    if (raw is Map) {
      return TodoModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  Future<void> saveTodo(TodoModel todo) async {
    await _box.put(todo.id, todo.toJson());
  }

  Future<void> mergeRemoteTodos(List<TodoModel> remoteTodos) async {
    final remoteIds = <String>{};

    for (final remote in remoteTodos) {
      remoteIds.add(remote.id);
      final local = getById(remote.id);
      if (local != null &&
          !local.isSynced &&
          local.updatedAt.isAfter(remote.updatedAt)) {
        // Preserve newer unsynced local changes
        continue;
      }
      await _box.put(remote.id, remote.copyWith(isSynced: true).toJson());
    }

    // Remove synced local items no longer returned as active on server,
    // while NEVER deleting unsynced local items.
    final keysToDelete = <dynamic>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        final local = TodoModel.fromJson(Map<String, dynamic>.from(raw));
        if (local.isSynced && !remoteIds.contains(local.id)) {
          keysToDelete.add(key);
        }
      }
    }

    if (keysToDelete.isNotEmpty) {
      await _box.deleteAll(keysToDelete);
    }
  }
}

final todoLocalDataSourceProvider = Provider<TodoLocalDataSource>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return TodoLocalDataSource(storage);
});
