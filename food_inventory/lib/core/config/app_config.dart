import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/di/injection_container.dart';

class AppConfig {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String rootImagePath = 'http://10.0.2.2:3000/uploads';

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
  static const String storageIdKey = 'current_storage'; //mã kho
  static const String codeStorageKey = 'storage_key'; //mã tham gia
  static const String nameStorageKey = 'storage_name'; //tên kho
  static const lastSuggestedDishKey =
      'last_suggested_dish'; // Lưu thời gian gợi ý món ăn
  static const suggestedDishesKey =
      'suggested_dishes_json'; //Lưu nội dung món ăn gợi ý (json)

  //supabase
  ///hay còn gọi là anonKey
  static const apiKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4dnR1dG95aWpicHBubWFiYXZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5MTE1MzIsImV4cCI6MjA2MTQ4NzUzMn0.k5cYjbkHVlXpyEvX5a9EShvLZ82qAgssR6XNqgQLyfI";
  static const supabaseServiceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4dnR1dG95aWpicHBubWFiYXZoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NTkxMTUzMiwiZXhwIjoyMDYxNDg3NTMyfQ.V_eEH5cg3id5tkuNmf7-slUJasq6v_ZnH2ObNfXKzDY';
  static const supabaseProjectUrl = 'https://yxvtutoyijbppnmabavh.supabase.co';

  // App constants
  static const int requestTimeout = 30000;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB

  //getter
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  //default value
  static const String geminiApiEndpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"; //geminiApiEndpoint

  //storageId
  static int storageId() {
    final storageId = getIt<SharedPreferences>().getInt(storageIdKey);
    return storageId ?? -1;
  }
}
