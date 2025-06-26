import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import '../core/network/dio_client.dart';
import '../core/config/app_config.dart';
import '../core/di/injection_container.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/users";

  // Đăng nhập
  Future<User> login(String email, String password, bool rememberMe) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw ArgumentError('Email và mật khẩu không được để trống');
      }

      final response = await _dioClient.post(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception(
            'Đăng nhập thất bại: ${response.data?['message'] ?? 'Lỗi không xác định'}');
      }

      final User user;
      try {
        user = User.fromJson(response.data['user']);
      } catch (e) {
        throw Exception('Dữ liệu người dùng không hợp lệ');
      }

      final prefs = getIt<SharedPreferences>();
      final reponseData = response.data;
      //lưu token
      await Future.wait([
        prefs.setString(AppConfig.accessTokenKey, reponseData['accessToken']),
        prefs.setString(AppConfig.refreshTokenKey, reponseData['refreshToken']),
      ]);
      //Lưu dữ liệu người dùng
      await prefs.setInt(AppConfig.userIdKey, user.id);
      await prefs.setString(AppConfig.userEmailKey, user.email);

      if (user.phone != null) {
        await prefs.setString(AppConfig.userPhoneKey, user.phone!);
      }

      if (user.fullName != null) {
        await prefs.setString(AppConfig.userNameKey, user.fullName!);
      }

      if (user.gender != null) {
        await prefs.setString(AppConfig.genderKey, user.gender!);
      }

      if (user.avatarUrl != null) {
        await prefs.setString(AppConfig.avatarUrlKey, user.avatarUrl!);
      }

      await Future.wait([
        prefs.setString(AppConfig.userKey, user.toJson().toString()),
        prefs.setInt(AppConfig.userIdKey, user.id),
      ]);

      //Lưu dữ liệu kho
      if (reponseData['storage'] != null) {
        final storageData = reponseData['storage'];
        if (storageData['id'] != null) {
          await prefs.setInt(AppConfig.currentStorageKey, storageData['id']);
        }

        if (storageData['key'] != null) {
          await prefs.setString(AppConfig.codeStorageKey, storageData['key']);
        }

        if (storageData['name'] != null) {
          await prefs.setString(AppConfig.nameStorageKey, storageData['name']);
        }
      }

      if (rememberMe) {
        await prefs.setString(
            AppConfig.lastLoginTimeKey, DateTime.now().toIso8601String());
      }

      // In ra các giá trị đã lưu
      // await printSavedUserAndStoragePrefs();

      return user;
    } on DioException catch (e) {
      throw Exception(
          'Lỗi kết nối: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  Future<void> printSavedUserAndStoragePrefs() async {
    final prefs = getIt<SharedPreferences>();

    final data = {
      'accessToken': prefs.getString(AppConfig.accessTokenKey),
      'refreshToken': prefs.getString(AppConfig.refreshTokenKey),
      'userId': prefs.getInt(AppConfig.userIdKey),
      'email': prefs.getString(AppConfig.userEmailKey),
      'phone': prefs.getString(AppConfig.userPhoneKey),
      'fullName': prefs.getString(AppConfig.userNameKey),
      'gender': prefs.getString(AppConfig.genderKey),
      'avatarUrl': prefs.getString(AppConfig.avatarUrlKey),
      'userJson': prefs.getString(AppConfig.userKey),
      'storageId': prefs.getInt(AppConfig.currentStorageKey),
      'storageKey': prefs.getString(AppConfig.codeStorageKey),
      'storageName': prefs.getString(AppConfig.nameStorageKey),
      'lastLoginTime': prefs.getString(AppConfig.lastLoginTimeKey),
    };

    print("📦 Dữ liệu đã lưu trong SharedPreferences:");
    data.forEach((key, value) {
      print("• $key: ${value ?? 'null'}");
    });
  }

  Future<bool> checkLoggedIn() async {
    final prefs = getIt<SharedPreferences>();
    final lastLoginStr = prefs.getString(AppConfig.lastLoginTimeKey);

    if (lastLoginStr == null) return false; // Chưa từng đăng nhập

    final lastLoginTime = DateTime.tryParse(lastLoginStr);
    if (lastLoginTime == null) return false;

    final currentTime = DateTime.now();
    final difference = currentTime.difference(lastLoginTime);

    // Nếu bé hơn 5 ngày
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
      final response = await _dioClient.post('$baseUrl/register', data: {
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
      final prefs = getIt<SharedPreferences>();
      final refreshToken = prefs.getString(AppConfig.refreshTokenKey);
      final response = await _dioClient
          .post('$baseUrl/refreshToken', data: {'refresh_token': refreshToken});

      await prefs.setString(
          AppConfig.accessTokenKey, response.data['accessToken']);
      await prefs.setString(
          AppConfig.lastLoginTimeKey, DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Đăng xuất
  Future<bool> logout() async {
    try {
      final response = await _dioClient.post(
        '$baseUrl/logout',
        options: Options(
          headers: {'Content-Type': 'application/json'},
          extra: {'withCredentials': true},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Logout failed with status ${response.statusCode}');
      }

      final prefs = getIt<SharedPreferences>();
      await Future.wait([
        // Token
        prefs.remove(AppConfig.accessTokenKey),
        prefs.remove(AppConfig.refreshTokenKey),

        // User info
        prefs.remove(AppConfig.userIdKey),
        prefs.remove(AppConfig.userEmailKey),
        prefs.remove(AppConfig.userPhoneKey),
        prefs.remove(AppConfig.userNameKey),
        prefs.remove(AppConfig.genderKey),
        prefs.remove(AppConfig.avatarUrlKey),
        prefs.remove(AppConfig.userKey),

        // Storage info
        prefs.remove(AppConfig.currentStorageKey),
        prefs.remove(AppConfig.codeStorageKey),
        prefs.remove(AppConfig.nameStorageKey),

        // Remember me
        prefs.remove(AppConfig.lastLoginTimeKey),
      ]);

      return true;
    } catch (e) {
      debugPrint('Logout error: $e');
      return false;
    }
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
  Future<int?> getUserId() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final userId = prefs.getInt(AppConfig.userIdKey);

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
        prefs.containsKey(AppConfig.accessTokenKey);
  }
}
