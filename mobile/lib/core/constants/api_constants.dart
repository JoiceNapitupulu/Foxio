import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Base URL untuk backend ASP.NET Core (port HTTP: 5188 dari launchSettings.json).
  /// Dapat di-override saat build/run via:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5188/api`
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:5188/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5188/api';
    }
    return 'http://localhost:5188/api';
  }

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Todos Endpoints
  static const String todos = '/todos';
  static String todoById(String id) => '/todos/$id';
  static String todoComplete(String id) => '/todos/$id/complete';

  // Habits Endpoints
  static const String habits = '/habits';
  static String habitById(String id) => '/habits/$id';
  static String habitLog(String id) => '/habits/$id/log';

  // Stats Endpoints
  static const String statsOverview = '/stats/overview';
  static const String statsWeekly = '/stats/weekly';

  // Sync Endpoint
  static const String sync = '/sync';
}
