import 'dart:convert';

import '../../../core/network/dio_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/di/injection_container.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/users";

  // Đăng nhập
  Future<User> login(String email, String password, bool rememberMe) async {
    try {
      final response = await _dioClient.post('$baseUrl/login', data: {
        'email': email,
        'password': password,
      });

      final user = User.fromJson(response.data['user']);

      if (rememberMe) {
        // Lưu token và user data
        final prefs = getIt<SharedPreferences>();
        await prefs.setString(AppConfig.tokenKey, response.data['accessToken']);
        await prefs.setString(AppConfig.userKey, user.toJson().toString());
        await prefs.setString(AppConfig.userId, user.userId);
        await prefs.setString(
            AppConfig.lastLoginTimeKey, DateTime.now().toIso8601String());
        await prefs.setString(AppConfig.currentStorageKey,
            response.data['storage_id'].toString());
      }

      return user;
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  Future<bool> checkLoggedIn() async {
    final prefs = getIt<SharedPreferences>();
    final lastLoginStr = prefs.getString(AppConfig.lastLoginTimeKey);

    if (lastLoginStr == null) return false; // Chưa từng đăng nhập

    final lastLoginTime = DateTime.tryParse(lastLoginStr);
    if (lastLoginTime == null) return false;

    final currentTime = DateTime.now();
    final difference = currentTime.difference(lastLoginTime);

    // Nếu bé ngày
    return difference.inDays <= 5;
  }

  // Đăng ký
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required String gender,
    String? phone,
  }) async {
    try {
      var uuid = const Uuid();
      String userId = uuid.v4();
      final response = await _dioClient.post('$baseUrl/register', data: {
        'user_id': userId,
        'email': email,
        'password_hash': password,
        'full_name': fullName,
        'phone': phone,
        'gender': gender,
      });

      final user = User.fromJson(response.data);

      return user;
    } catch (e) {
      print(e.toString());
      throw Exception('Đăng ký thất bại: ${e.toString()}');
    }
  }

  //Refresh Token
  Future<bool> refreshToken() async {
    try {
      final response = await _dioClient.post(
        '$baseUrl/refreshToken',
      );

      final prefs = getIt<SharedPreferences>();
      await prefs.setString(AppConfig.tokenKey, response.data['accessToken']);
      await prefs.setString(
          AppConfig.lastLoginTimeKey, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.remove(AppConfig.userKey);
    await prefs.remove(AppConfig.tokenKey);
  }

  // Lấy user hiện tại
  Future<User?> getCurrentUser() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final userData = prefs.getString(AppConfig.userKey);

      if (userData != null) {
        final decodedData =
            jsonDecode(userData); // <- giải mã JSON string thành Map
        return User.fromJson(decodedData);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Lấy user hiện tại
  Future<String?> getUserId() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final userId = prefs.getString(AppConfig.userId);

      if (userId != null) {
        return userId;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Kiểm tra đã đăng nhập
  Future<bool> isLoggedIn() async {
    final prefs = getIt<SharedPreferences>();
    return prefs.containsKey(AppConfig.userKey) &&
        prefs.containsKey(AppConfig.tokenKey);
  }
}
