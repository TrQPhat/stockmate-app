import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/features/storage/models/storage.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/config/app_config.dart';

class UserRepository {
  final DioClient _dioClient;

  UserRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/storages";

  Future<Storage> createStorage({
    required String name,
  }) async {
    try {
      final prefs = getIt<SharedPreferences>();
      final userId = prefs.getString(AppConfig.userIdKey);
      final response = await _dioClient.post(
        baseUrl,
        data: {
          'name': name,
          'owner_id': userId,
        },
      );
      await prefs.setString(
          AppConfig.currentStorageKey, response.data['id'] ?? "error");
      await prefs.setString(
          AppConfig.codeStorageKey, response.data['key'] ?? "error");
      return Storage.fromJson(response.data); // Trả về storage vừa tạo
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['error'] ?? 'Lỗi không xác định khi tạo storage';
      throw Exception(errorMessage);
    }
  }
}
