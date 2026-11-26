class ApiConstants {
  ApiConstants._();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Base URL untuk backend ASP.NET Core (port HTTP: 5188 dari launchSettings.json).
  /// - Chrome / Desktop: langsung mengakses http://localhost:5188/api
  /// - HP Android Fisik via Kabel USB: menggunakan `adb reverse tcp:5188 tcp:5188`
  ///   (otomatis dijalankan oleh start-foxio.bat) sehingga http://localhost:5188/api
  ///   di HP langsung terhubung ke laptop lewat kabel USB.
  /// - HP Android via Wi-Fi (tanpa kabel): override saat build/run dengan:
  ///   `flutter run --dart-define=API_BASE_URL=http://<IP_LAPTOP>:5188/api`
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    return 'http://localhost:5188/api';
  }

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/profile';

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
