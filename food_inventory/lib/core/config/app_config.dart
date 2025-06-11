class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String apiVersion = 'v1';
  static const String fullApiUrl = '$baseUrl/api/$apiVersion';

  // Storage keys
  static const String tokenKey = 'access_token';
  static const String userKey = 'user_data';
  static const String userId = 'user_id';
  static const String currentStorageKey = 'current_storage';
  static const String lastLoginTimeKey = 'last_login_time';

  // App constants
  static const int requestTimeout = 30000;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
}
