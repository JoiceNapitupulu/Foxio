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
    await _secureStorage.saveUserJson(result.user.toJson(includeAvatar: false));
    await _localStorage.saveUserAvatar(
      result.user.id,
      result.user.avatarData,
      isDirty: false,
    );
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
    await _secureStorage.saveUserJson(result.user.toJson(includeAvatar: false));
    await _localStorage.saveUserAvatar(
      result.user.id,
      result.user.avatarData,
      isDirty: false,
    );
    return result.user;
  }

  Future<UserEntity> _syncAvatarWithLocal(UserModel remoteUser) async {
    if (_localStorage.isUserAvatarDirty(remoteUser.id)) {
      final localAvatar = _localStorage.getUserAvatar(remoteUser.id);
      try {
        final synced = await _remote.updateProfile(
          avatarData: localAvatar,
          clearAvatar: localAvatar == null,
        );
        await _localStorage.saveUserAvatar(
          synced.id,
          synced.avatarData,
          isDirty: false,
        );
        return synced;
      } catch (_) {
        return remoteUser.copyWith(
          avatarData: localAvatar,
          clearAvatar: localAvatar == null,
        );
      }
    }

    await _localStorage.saveUserAvatar(
      remoteUser.id,
      remoteUser.avatarData,
      isDirty: false,
    );
    return remoteUser;
  }

  UserEntity _hydrateOfflineUser(Map<String, dynamic> cachedJson) {
    final cached = UserModel.fromJson(cachedJson);
    final localAvatar = _localStorage.getUserAvatar(cached.id);
    if (_localStorage.isUserAvatarDirty(cached.id)) {
      return cached.copyWith(
        avatarData: localAvatar,
        clearAvatar: localAvatar == null,
      );
    }
    return cached.copyWith(avatarData: localAvatar ?? cached.avatarData);
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
      await _secureStorage.saveUserJson(user.toJson(includeAvatar: false));
      return await _syncAvatarWithLocal(user);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _secureStorage.clearAll();
        await _localStorage.clearAll();
        return null;
      }
      // Offline-first fallback: allow entry if we have cached user profile
      if (cachedJson != null) {
        return _hydrateOfflineUser(cachedJson);
      }
      return null;
    } catch (_) {
      if (cachedJson != null) {
        return _hydrateOfflineUser(cachedJson);
      }
      return null;
    }
  }

  @override
  Future<UserEntity> updateAvatar({
    required UserEntity currentUser,
    String? avatarData,
    bool clearAvatar = false,
  }) async {
    final nextAvatar = clearAvatar ? null : avatarData?.trim();
    await _localStorage.saveUserAvatar(
      currentUser.id,
      nextAvatar,
      isDirty: true,
    );
    final localUpdated = currentUser.copyWith(
      avatarData: nextAvatar,
      clearAvatar: clearAvatar || nextAvatar == null,
    );

    try {
      final remoteUpdated = await _remote.updateProfile(
        avatarData: nextAvatar,
        clearAvatar: clearAvatar,
      );
      await _localStorage.saveUserAvatar(
        remoteUpdated.id,
        remoteUpdated.avatarData,
        isDirty: false,
      );
      await _secureStorage.saveUserJson(
        remoteUpdated.toJson(includeAvatar: false),
      );
      return remoteUpdated;
    } catch (_) {
      // Offline-first: simpan perubahan lokal & sinkronkan ketika kembali online
      return localUpdated;
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
