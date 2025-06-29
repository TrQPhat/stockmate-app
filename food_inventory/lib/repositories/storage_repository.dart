import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/models/storage.dart';

import '../core/network/dio_client.dart';
import '../core/config/app_config.dart';

class StorageRepository {
  final DioClient _dioClient;

  StorageRepository(this._dioClient);

  final baseUrl = "/storages";

  Future<Storage> createStorage({
    required String name,
  }) async {
    try {
      final prefs = getIt<SharedPreferences>();
      final userId = prefs.getInt(AppConfig.userIdKey);

      final response = await _dioClient.post(
        "$baseUrl/create",
        data: {
          'name': name,
          'owner_id': userId,
        },
      );
      final data = response.data;

      if (data['id'] != null) {
        await prefs.setInt(AppConfig.storageIdKey, data['id']);
      }

      if (data['key'] != null) {
        await prefs.setString(AppConfig.codeStorageKey, data['key']);
      }

      if (data['name'] != null) {
        await prefs.setString(AppConfig.nameStorageKey, data['name']);
      }
      return Storage.fromJson(data); // Trả về storage vừa tạo
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['error'] ?? 'Lỗi không xác định khi tạo storage';
      print("Error creating storage: $errorMessage");
      throw Exception(errorMessage);
    }
  }

  Future<Storage> joinStorageByKey({
    required String key,
  }) async {
    try {
      final prefs = getIt<SharedPreferences>();
      final userId = prefs.getInt(AppConfig.userIdKey);

      if (userId == null) {
        throw Exception("Người dùng chưa đăng nhập");
      }

      final response = await _dioClient.post(
        "$baseUrl/join/key",
        data: {
          'key': key,
          'user_id': userId,
        },
      );

      final data = response.data['storage'];
      if (data['id'] != null) {
        await prefs.setInt(AppConfig.storageIdKey, data['id']);
      }

      if (data['key'] != null) {
        await prefs.setString(AppConfig.codeStorageKey, data['key']);
      }

      if (data['name'] != null) {
        await prefs.setString(AppConfig.nameStorageKey, data['name']);
      }
      return Storage.fromJson(data); // Trả về storage vừa tham gia
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['error'] ?? 'Lỗi không xác định khi tham gia kho';
      print("Error joining storage: $errorMessage");
      throw Exception(errorMessage);
    }
  }
}
