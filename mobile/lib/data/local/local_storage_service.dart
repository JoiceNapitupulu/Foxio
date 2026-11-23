import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String authBoxName = 'foxio_auth';
  static const String todosBoxName = 'foxio_todos';
  static const String habitsBoxName = 'foxio_habits';

  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'current_user';
  static const String _lastSyncedAtKey = 'last_synced_at';

  /// Inisialisasi Hive dan buka semua box utama sebelum runApp().
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(authBoxName),
      Hive.openBox(todosBoxName),
      Hive.openBox(habitsBoxName),
    ]);
  }

  Box get _authBox => Hive.box(authBoxName);
  Box get todosBox => Hive.box(todosBoxName);
  Box get habitsBox => Hive.box(habitsBoxName);

  // --- Auth & Token ---

  Future<void> saveToken(String token) async {
    await _authBox.put(_tokenKey, token);
  }

  String? getToken() {
    return _authBox.get(_tokenKey) as String?;
  }

  bool get hasToken {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveUser(Map<String, dynamic> userJson) async {
    await _authBox.put(_userKey, userJson);
  }

  Map<String, dynamic>? getUser() {
    final raw = _authBox.get(_userKey);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  // --- Sync Metadata ---

  Future<void> saveLastSyncedAt(DateTime timestamp) async {
    await _authBox.put(_lastSyncedAtKey, timestamp.toUtc().toIso8601String());
  }

  DateTime? getLastSyncedAt() {
    final raw = _authBox.get(_lastSyncedAtKey) as String?;
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  // --- Clear on Logout ---

  Future<void> clearAll() async {
    await Future.wait([
      _authBox.clear(),
      todosBox.clear(),
      habitsBox.clear(),
    ]);
  }
}

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});
