import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/models/storage.dart';
import 'package:stock_mate/models/user.dart' as appModels;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/network/dio_client.dart';
import '../core/config/app_config.dart';

class StorageRepository {
  final DioClient _dioClient;

  StorageRepository(this._dioClient);

  final baseUrl = "/storages";

  // Future<void> createConversation(int storageId) async {

  Future<void> createConversation(int storageId) async {
    // Lấy SupabaseClient từ GetIt
    final supabase = getIt<SupabaseClient>();

    try {
      final response = await supabase
          .from('conversations')
          .insert({
            'id': storageId,
            'status': 'active',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      if (response != null) {
        print('Tạo conversation thành công cho Storage ID = $storageId');
      } else {
        throw Exception(
            'Lỗi tạo conversation: Phản hồi rỗng hoặc không mong muốn.');
      }
    } on PostgrestException catch (e) {
      print('Lỗi tạo conversation từ Supabase: ${e.message}');
      throw Exception('Lỗi tạo conversation từ Supabase: ${e.message}');
    } catch (e) {
      print('Lỗi tạo conversation không xác định: $e');
      throw Exception('Lỗi tạo conversation không xác định: $e');
    }
  }

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
        await createConversation(data['id']);
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

  Future<List<appModels.User>> getAllUsersInStorage() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final storageId = prefs.getInt(AppConfig.storageIdKey);
      if (storageId == null) {
        throw Exception("Thiếu mã kho");
      }
      final response = await _dioClient.get(
        "$baseUrl/member/$storageId",
      );

      final List<dynamic> usersJson = response.data['members'];
      final List<appModels.User> users =
          usersJson.map((json) => appModels.User.fromJson(json)).toList();

      return users;
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Không thể tải danh sách thành viên';
      print("Lỗi khi lấy thành viên kho: $errorMessage");
      throw Exception(errorMessage);
    }
  }

  Future<bool> updateMemberRole(int userId, String role) async {
    try {
      final prefs = getIt<SharedPreferences>();
      final storageId = prefs.getInt(AppConfig.storageIdKey);

      if (storageId == null) {
        throw Exception("Không tìm thấy storageId trong SharedPreferences");
      }

      final response = await _dioClient.put(
        "$baseUrl/member/$storageId/$userId/role",
        data: {'role': role},
      );

      final data = response.data;
      if (data['success'] == true) {
        print("✅ Cập nhật role thành công: ${data['message']}");
        return true;
      } else {
        print("❌ Lỗi khi cập nhật role thành viên: ${data['error']}");
        return false;
      }
    } on DioException {
      return false;
    } catch (e) {
      print("Lỗi không xác định: $e");
      return false;
    }
  }

  /// Gọi API để xoá một thành viên ra khỏi kho hiện tại
  Future<bool> removeMember(int userId) async {
    try {
      // Lấy storageId đang được lưu trên thiết bị
      final prefs = getIt<SharedPreferences>();
      final storageId = prefs.getInt(AppConfig.storageIdKey);

      // Nếu không có storageId, không thể thực hiện yêu cầu
      if (storageId == null) {
        return false; // hoặc throw Exception tùy theo cách xử lý lỗi của bạn
      }

      // Gọi API với phương thức DELETE
      final response = await _dioClient.delete(
        "$baseUrl/member/$storageId/$userId/role",
      );

      // Xử lý kết quả trả về từ server
      final data = response.data;
      if (data['success'] == true) {
        return true;
      } else {
        return false;
      }
    } on DioException {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<appModels.User?> inviteMember(String email, String role) async {
    try {
      final prefs = getIt<SharedPreferences>();
      final storageId = prefs.getInt(AppConfig.storageIdKey);
      if (storageId == null) {
        return null;
      }

      final response = await _dioClient.post(
        "$baseUrl/member/$storageId",
        data: {'email': email, 'role': role},
      );

      final data = response.data;
      if (data['success'] == true && data['member'] != null) {
        // **[THAY ĐỔI]** Dùng User.fromJson để parse
        return appModels.User.fromJson(data['member']);
      } else {
        throw Exception(data['error'] ?? "Mời thành viên thất bại");
      }
    } on DioException catch (e) {
      final error = e.response?.data?['error'] ?? "Lỗi mạng khi mời thành viên";
      throw Exception(error);
    } catch (e) {
      rethrow; // Ném lại lỗi để BLoC xử lý
    }
  }
}
