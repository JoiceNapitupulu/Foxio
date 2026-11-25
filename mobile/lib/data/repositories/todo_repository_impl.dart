import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/secure_token_storage.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../local/todo_local_datasource.dart';
import '../models/todo_model.dart';
import '../remote/todo_remote_datasource.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource _remote;
  final TodoLocalDataSource _local;
  final SecureTokenStorage _secureStorage;

  static const Uuid _uuid = Uuid();
  static const int _todoCompletionPoints = 10;

  TodoRepositoryImpl(this._remote, this._local, this._secureStorage);

  int _calculateLevel(int totalPoints) {
    if (totalPoints <= 100) return 1;
    int level = 1;
    while (totalPoints > 25 * level * (level + 3)) {
      level++;
    }
    return level;
  }

  bool _isNetworkOrOfflineError(ApiException e) => e.statusCode == null;

  @override
  Future<List<TodoEntity>> getTodos() async {
    try {
      final remoteList = await _remote.getTodos();
      await _local.mergeRemoteTodos(remoteList);
      return _local.getActiveTodos();
    } on ApiException catch (e) {
      if (_isNetworkOrOfflineError(e)) {
        return _local.getActiveTodos();
      }
      rethrow;
    } catch (_) {
      return _local.getActiveTodos();
    }
  }

  @override
  Future<TodoEntity> createTodo({
    required String title,
    String? description,
    DateTime? deadline,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final cleanDesc =
        (description != null && description.trim().isNotEmpty)
            ? description.trim()
            : null;

    final localTodo = TodoModel(
      id: id,
      title: title.trim(),
      description: cleanDesc,
      deadline: deadline,
      isCompleted: false,
      pointsAwarded: false,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      isSynced: false,
    );

    await _local.saveTodo(localTodo);

    try {
      final remoteTodo = await _remote.createTodo(
        id: id,
        title: title,
        description: cleanDesc,
        deadline: deadline,
      );
      final synced = remoteTodo.copyWith(isSynced: true);
      await _local.saveTodo(synced);
      return synced;
    } on ApiException catch (e) {
      if (_isNetworkOrOfflineError(e)) {
        return localTodo;
      }
      rethrow;
    } catch (_) {
      return localTodo;
    }
  }

  @override
  Future<TodoEntity> updateTodo({
    required String id,
    required String title,
    String? description,
    DateTime? deadline,
  }) async {
    final existing = _local.getById(id);
    final now = DateTime.now();
    final cleanDesc =
        (description != null && description.trim().isNotEmpty)
            ? description.trim()
            : null;

    final localUpdated = (existing ??
            TodoModel(
              id: id,
              title: title.trim(),
              createdAt: now,
              updatedAt: now,
            ))
        .copyWith(
      title: title.trim(),
      description: cleanDesc,
      clearDescription: cleanDesc == null,
      deadline: deadline,
      clearDeadline: deadline == null,
      updatedAt: now,
      isSynced: false,
    );

    await _local.saveTodo(localUpdated);

    try {
      final remoteTodo = await _remote.updateTodo(
        id: id,
        title: title,
        description: cleanDesc,
        deadline: deadline,
      );
      final synced = remoteTodo.copyWith(isSynced: true);
      await _local.saveTodo(synced);
      return synced;
    } on ApiException catch (e) {
      if (_isNetworkOrOfflineError(e)) {
        return localUpdated;
      }
      rethrow;
    } catch (_) {
      return localUpdated;
    }
  }

  @override
  Future<CompleteTodoResult> toggleComplete({
    required String id,
    required bool isCompleted,
  }) async {
    try {
      final response = await _remote.completeTodo(
        id: id,
        isCompleted: isCompleted,
      );
      final synced = response.todo.copyWith(isSynced: true);
      await _local.saveTodo(synced);
      await _updateCachedUserStats(response.totalPoints, response.level);
      return response.toResult();
    } on ApiException catch (e) {
      if (!_isNetworkOrOfflineError(e)) rethrow;
    } catch (_) {
      // Fallback to offline completion below
    }

    // Offline completion fallback (preserves anti-farming guard & level curve)
    final existing = _local.getById(id);
    if (existing == null) {
      throw const ApiException('Task tidak ditemukan di penyimpanan lokal.');
    }

    final now = DateTime.now();
    final int pointsEarned =
        (isCompleted && !existing.pointsAwarded) ? _todoCompletionPoints : 0;

    final updated = existing.copyWith(
      isCompleted: isCompleted,
      pointsAwarded: existing.pointsAwarded || isCompleted,
      updatedAt: now,
      isSynced: false,
    );
    await _local.saveTodo(updated);

    final cachedUser = await _secureStorage.getUserJson() ?? <String, dynamic>{};
    final int oldPoints = (cachedUser['totalPoints'] as num?)?.toInt() ?? 0;
    final int oldLevel = (cachedUser['level'] as num?)?.toInt() ?? 1;
    final int newTotalPoints = oldPoints + pointsEarned;
    final int newLevel = _calculateLevel(newTotalPoints);
    final bool leveledUp = newLevel > oldLevel;

    await _updateCachedUserStats(newTotalPoints, newLevel);

    return CompleteTodoResult(
      todo: updated,
      pointsEarned: pointsEarned,
      totalPoints: newTotalPoints,
      level: newLevel,
      leveledUp: leveledUp,
    );
  }

  @override
  Future<void> deleteTodo(String id) async {
    final existing = _local.getById(id);
    final now = DateTime.now();

    if (existing != null) {
      await _local.saveTodo(
        existing.copyWith(
          isDeleted: true,
          updatedAt: now,
          isSynced: false,
        ),
      );
    }

    try {
      await _remote.deleteTodo(id);
      if (existing != null) {
        await _local.saveTodo(
          existing.copyWith(
            isDeleted: true,
            updatedAt: now,
            isSynced: true,
          ),
        );
      }
    } on ApiException catch (e) {
      if (_isNetworkOrOfflineError(e)) {
        return;
      }
      rethrow;
    } catch (_) {
      // Kept soft-deleted locally with isSynced=false for future sync
    }
  }

  Future<void> _updateCachedUserStats(int totalPoints, int level) async {
    final cachedUser = await _secureStorage.getUserJson();
    if (cachedUser != null) {
      cachedUser['totalPoints'] = totalPoints;
      cachedUser['level'] = level;
      await _secureStorage.saveUserJson(cachedUser);
    }
  }
}

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final remote = ref.watch(todoRemoteDataSourceProvider);
  final local = ref.watch(todoLocalDataSourceProvider);
  final secureStorage = ref.watch(secureTokenStorageProvider);
  return TodoRepositoryImpl(remote, local, secureStorage);
});
