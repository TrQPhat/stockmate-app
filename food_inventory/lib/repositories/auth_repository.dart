import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stock_mate/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../core/network/dio_client.dart';
import '../core/config/app_config.dart';
import '../core/di/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final DioClient _dioClient;
  final supabase.SupabaseClient _supabaseClient =
      supabase.Supabase.instance.client;

  AuthRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/users";

  // Đăng ký tài khoản
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String gender,
    String? phone,
  }) async {
    try {
      // 1. Đăng ký tài khoản qua Supabase Auth
      final authResponse = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'http://localhost:3001/verify',
      );
      if (authResponse.user != null) {
        try {
          // 2. Gửi thông tin tạo người dùng lên backend riêng
          await _dioClient.post('$baseUrl/register', data: {
            'email': email,
            'password': password,
            'full_name': fullName,
            'phone': phone,
            'gender': gender,
          });
        } on DioException catch (e) {
          final errorData = e.response?.data;

          // Kiểm tra lỗi trả về từ API
          final errorMessage = switch (errorData) {
            Map m when m['message'] != null => m['message'].toString(),
            _ => 'Lỗi không xác định từ máy chủ.',
          };

          throw Exception('Không thể tạo người dùng: $errorMessage');
        }
      } else {
        throw Exception("Đăng ký tài khoản thất bại. Vui lòng thử lại.");
      }
    } on supabase.AuthException catch (e) {
      // Lỗi đăng ký Supabase (email đã tồn tại, mật khẩu yếu, ...)
      String message;
      switch (e.message.toLowerCase()) {
        case 'user already registered':
          message = 'Email đã được sử dụng. Vui lòng dùng email khác.';
          break;
        case 'password should be at least 6 characters':
          message = 'Mật khẩu phải có ít nhất 6 ký tự.';
          break;
        default:
          message = 'Thông tin người dùng không hợp lệ. Vui lòng kiểm tra lại!';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  // II. Quy trình Đăng nhập bằng email và mật khẩu
  Future<User> login(String email, String password, bool rememberMe) async {
    try {
      // 3. Gửi yêu cầu đăng nhập đến backend để lấy token và thông tin chi tiết
      final response = await _dioClient.post(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception(
            'Đăng nhập thất bại: ${response.data?['message'] ?? 'Lỗi không xác định'}');
      }

      final User user = User.fromJson(response.data['user']);
      final prefs = getIt<SharedPreferences>();
      final responseData = response.data;

      // 6. Lưu thông tin
      await _saveUserData(prefs, user, responseData, rememberMe);

      return user;
      // } on supabase.AuthException catch (e) {
      //   throw Exception("Sai tên đăng nhập hoặc mật khẩu.");
    } on DioException catch (e) {
      throw Exception(
          'Lỗi kết nối: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  // III. Quy trình Đăng nhập bằng Google
  Future<User> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Người dùng đã huỷ đăng nhập Google.');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Không lấy được token từ Google.');
      }

      final authResponse = await _supabaseClient.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (authResponse.user == null || authResponse.session == null) {
        throw Exception('Xác thực Supabase thất bại.');
      }

      final user = authResponse.user!;
      final response = await _dioClient.post(
        '$baseUrl/google',
        data: {
          'email': user.email,
          'full_name': user.userMetadata?['full_name'],
        },
      );

      final appUser = User.fromJson(response.data['user']);
      final prefs = getIt<SharedPreferences>();
      await _saveUserData(prefs, appUser, response.data, true);

      return appUser;
    } catch (e) {
      throw Exception('Đăng nhập Google thất bại: ${e.toString()}');
    }
  }

  // Hàm hỗ trợ lưu dữ liệu người dùng
  Future<void> _saveUserData(SharedPreferences prefs, User user,
      Map<String, dynamic> responseData, bool rememberMe) async {
    await Future.wait([
      prefs.setString(AppConfig.accessTokenKey, responseData['accessToken']),
      prefs.setString(AppConfig.refreshTokenKey, responseData['refreshToken']),
    ]);
    await prefs.setString(AppConfig.userKey, jsonEncode(user.toJson()));
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

    if (responseData['storage'] != null) {
      final storageData = responseData['storage'];
      if (storageData['id'] != null) {
        await prefs.setInt(AppConfig.storageIdKey, storageData['id']);
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
  }

  // Các hàm còn lại giữ nguyên...
  Future<bool> checkLoggedIn() async {
    final prefs = getIt<SharedPreferences>();
    final lastLoginStr = prefs.getString(AppConfig.lastLoginTimeKey);

    if (lastLoginStr == null) return false;

    final lastLoginTime = DateTime.tryParse(lastLoginStr);
    if (lastLoginTime == null) return false;

    final currentTime = DateTime.now();
    final difference = currentTime.difference(lastLoginTime);

    return difference.inDays <= 5;
  }

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

  Future<bool> logout() async {
    try {
      await _supabaseClient.auth.signOut();
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
        prefs.remove(AppConfig.accessTokenKey),
        prefs.remove(AppConfig.refreshTokenKey),
        prefs.remove(AppConfig.userKey),
        prefs.remove(AppConfig.userIdKey),
        prefs.remove(AppConfig.userEmailKey),
        prefs.remove(AppConfig.userPhoneKey),
        prefs.remove(AppConfig.userNameKey),
        prefs.remove(AppConfig.genderKey),
        prefs.remove(AppConfig.avatarUrlKey),
        prefs.remove(AppConfig.storageIdKey),
        prefs.remove(AppConfig.codeStorageKey),
        prefs.remove(AppConfig.nameStorageKey),
        prefs.remove(AppConfig.lastLoginTimeKey),
      ]);

      return true;
    } catch (e) {
      debugPrint('Logout error: $e');
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final userData = prefs.getString(AppConfig.userKey);

      if (userData != null) {
        final decodedData = jsonDecode(userData);
        return User.fromJson(decodedData);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

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

  Future<bool> isLoggedIn() async {
    final prefs = getIt<SharedPreferences>();
    return prefs.containsKey(AppConfig.userKey) &&
        prefs.containsKey(AppConfig.accessTokenKey);
  }
}
