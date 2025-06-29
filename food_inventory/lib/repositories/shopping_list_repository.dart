import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/core/network/dio_client.dart';
import 'package:stock_mate/models/shopping_list.dart';

class ShoppingListRepository {
  final DioClient _dioClient;
  final String _baseUrl = '/shopping';

  ShoppingListRepository(this._dioClient);

  Future<List<ShoppingList>> getShoppingLists() async {
    final prefs = getIt<SharedPreferences>();
    final storageId = prefs.getInt(AppConfig.storageIdKey);

    if (storageId == null) {
      throw Exception('Người dùng hiện tại chưa tham gia kho');
    }

    try {
      final response = await _dioClient.get("$_baseUrl/$storageId");

      final data = response.data;

      if (data is List) {
        return data.map((json) => ShoppingList.fromJson(json)).toList();
      } else {
        throw Exception('Dữ liệu trả về không hợp lệ');
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách mua sắm: ${e.toString()}');
    }
  }

  // Tạo danh sách mới
  Future<ShoppingList> createShoppingList(
      String name, String purpose, DateTime purchaseDate) async {
    final prefs = getIt<SharedPreferences>();
    final storageId = prefs.getInt(AppConfig.storageIdKey);
    if (storageId == null) {
      throw Exception('Người dùng hiện tại chưa tham gia kho');
    }
    try {
      final response = await _dioClient.post(_baseUrl, data: {
        'name': name,
        'purpose': purpose,
        'purchase_date': purchaseDate
            .toIso8601String()
            .substring(0, 10), // Format YYYY-MM-DD
        'storage_id': storageId,
      });
      return ShoppingList.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tạo danh sách: ${e.toString()}');
    }
  }

  // Xóa danh sách
  Future<void> deleteShoppingList(int listId) async {
    try {
      await _dioClient.delete('$_baseUrl/$listId');
    } catch (e) {
      throw Exception('Không thể xóa danh sách: ${e.toString()}');
    }
  }

  // Cập nhật danh sách
  Future<ShoppingList> updateShoppingList(
      int listId, String name, DateTime purchaseDate) async {
    try {
      final response = await _dioClient.put(
        '$_baseUrl/$listId',
        data: {
          'name': name,
          'purchase_date': purchaseDate
              .toIso8601String()
              .substring(0, 10), // Format YYYY-MM-DD
        },
      );
      return ShoppingList.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể cập nhật danh sách: ${e.toString()}');
    }
  }

  Future<void> completeShoppingList(int listId) async {
    try {
      await _dioClient.post('$_baseUrl/complete/$listId');
    } catch (e) {
      throw Exception('Xảy ra vấn đề không mong muốn, hãy thử lại sau.');
    }
  }
  //end
}
