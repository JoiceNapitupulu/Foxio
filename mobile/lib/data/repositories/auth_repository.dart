import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../local/local_storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _client;
  final LocalStorageService _storage;

  AuthRepository(this._client, this._storage);

  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.dio.post(
      ApiConstants.register,
      data: {
        'email': email.trim(),
        'password': password,
        'displayName': displayName.trim(),
      },
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final token = data['token'] as String;
    final user = UserModel.fromJson(data);

    await _storage.saveToken(token);
    await _storage.saveUser(user.toJson());
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      ApiConstants.login,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final token = data['token'] as String;
    final user = UserModel.fromJson(data);

    await _storage.saveToken(token);
    await _storage.saveUser(user.toJson());
    return user;
  }

  /// Muat sesi tersimpan (offline-first):
  /// 1. Jika tidak ada token -> return null.
  /// 2. Coba refresh profil dari server; jika sedang offline, gunakan cache lokal.
  Future<UserModel?> restoreSession() async {
    if (!_storage.hasToken) return null;

    final cached = _storage.getUser();
    try {
      final response = await _client.dio.get(ApiConstants.me);
      final user = UserModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      await _storage.saveUser(user.toJson());
      return user;
    } catch (_) {
      // Tetap bisa masuk ke aplikasi jika sedang offline selama ada cache user
      if (cached != null) {
        return UserModel.fromJson(cached);
      }
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(dioClientProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return AuthRepository(client, storage);
});
