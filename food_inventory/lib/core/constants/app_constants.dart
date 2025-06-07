class AppConstants {
  // API
  static const String baseUrl = 'https://your-api-url.com/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Categories
  static const List<String> productCategories = [
    'Thịt',
    'Rau củ',
    'Trái cây',
    'Gia vị',
    'Đồ khô',
    'Đồ uống',
    'Khác',
  ];
  
  // Units
  static const List<String> productUnits = [
    'kg',
    'g',
    'lít',
    'ml',
    'cái',
    'hộp',
    'gói',
    'chai',
    'lon',
  ];
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxNoteLength = 500;
}
