import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/todo_model.dart';

class TodoRemoteDataSource {
  final DioClient _client;

  TodoRemoteDataSource(this._client);

  Future<List<TodoModel>> getTodos() async {
    try {
      final response = await _client.dio.get(ApiConstants.todos);
      final rawList = response.data as List<dynamic>;
      return rawList
          .map(
            (e) => TodoModel.fromJson(
              Map<String, dynamic>.from(e as Map),
              isSyncedOverride: true,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<TodoModel> createTodo({
    required String id,
    required String title,
    String? description,
    DateTime? deadline,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.todos,
        data: {
          'id': id,
          'title': title.trim(),
          'description': description?.trim(),
          'deadline': deadline?.toUtc().toIso8601String(),
        },
      );
      return TodoModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        isSyncedOverride: true,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<TodoModel> updateTodo({
    required String id,
    required String title,
    String? description,
    DateTime? deadline,
  }) async {
    try {
      final response = await _client.dio.put(
        ApiConstants.todoById(id),
        data: {
          'title': title.trim(),
          'description': description?.trim(),
          'deadline': deadline?.toUtc().toIso8601String(),
        },
      );
      return TodoModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
        isSyncedOverride: true,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<CompleteTodoResponseModel> completeTodo({
    required String id,
    required bool isCompleted,
  }) async {
    try {
      final response = await _client.dio.patch(
        ApiConstants.todoComplete(id),
        data: {'isCompleted': isCompleted},
      );
      return CompleteTodoResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _client.dio.delete(ApiConstants.todoById(id));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final todoRemoteDataSourceProvider = Provider<TodoRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return TodoRemoteDataSource(client);
});
