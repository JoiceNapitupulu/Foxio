import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/secure_token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../local/local_storage_service.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';
import '../remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureTokenStorage _secureStorage;
  final LocalStorageService _localStorage;

  AuthRepositoryImpl(
    this._remote,
    this._secureStorage,
    this._localStorage,
  );

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final result = await _remote.login(
      LoginRequestModel(email: email, password: password),
    );
    await _secureStorage.saveToken(result.token);
    await _secureStorage.saveUserJson(result.user.toJson());
    return result.user;
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final result = await _remote.register(
      RegisterRequestModel(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
    await _secureStorage.saveToken(result.token);
    await _secureStorage.saveUserJson(result.user.toJson());
    return result.user;
  }

  @override
  Future<UserEntity?> restoreSession() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final cachedJson = await _secureStorage.getUserJson();
    try {
      final user = await _remote.getCurrentUser();
      await _secureStorage.saveUserJson(user.toJson());
      return user;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _secureStorage.clearAll();
        return null;
      }
      // Offline-first fallback: allow entry if we have cached user profile
      if (cachedJson != null) {
        return UserModel.fromJson(cachedJson);
      }
      return null;
    } catch (_) {
      if (cachedJson != null) {
        return UserModel.fromJson(cachedJson);
      }
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearAll();
    await _localStorage.clearAll();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureTokenStorageProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return AuthRepositoryImpl(remote, secureStorage, localStorage);
});
