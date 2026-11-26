import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSource(this._client);

  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _client.dio.get(ApiConstants.me);
      return UserModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserModel> updateProfile({
    String? displayName,
    String? avatarData,
    bool clearAvatar = false,
  }) async {
    try {
      final response = await _client.dio.put(
        ApiConstants.updateProfile,
        data: {
          if (displayName != null) 'displayName': displayName.trim(),
          if (!clearAvatar && avatarData != null) 'avatarData': avatarData,
          'clearAvatar': clearAvatar,
        },
      );
      return UserModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(client);
});
