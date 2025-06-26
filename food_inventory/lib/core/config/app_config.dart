class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'email';
  static const String userPhoneKey = 'phone';
  static const String userNameKey = 'name';
  static const String genderKey = 'gender';
  static const String avatarUrlKey = 'avatar_url';
  static const String lastLoginTimeKey = 'last_login_time';
  static const String currentStorageKey = 'current_storage'; //mã kho
  static const String codeStorageKey = 'storage_key'; //mã tham gia
  static const String nameStorageKey = 'storage_name'; //tên kho

  // App constants
  static const int requestTimeout = 30000;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
}
