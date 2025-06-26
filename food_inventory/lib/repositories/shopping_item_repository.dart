import 'package:stock_mate/core/network/dio_client.dart';
import 'package:stock_mate/models/shopping_list.dart';
import 'package:stock_mate/models/shopping_item.dart';

class ShoppingItemRepository {
  final DioClient _dioClient;
  final String _baseUrl = '/shopping';

  ShoppingItemRepository(this._dioClient);

  // Lấy chi tiết một danh sách
  Future<ShoppingList> getShoppingList(int listId) async {
    try {
      final response = await _dioClient.get('$_baseUrl/detail/$listId');
      print("data: ${response.data}");
      return ShoppingList.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải chi tiết danh sách: ${e.toString()}');
    }
  }

  // Thêm một item vào danh sách
  Future<ShoppingItem> addItemToList({
    required int listId,
    required String itemName,
    required int quantity,
    required String unit,
    required DateTime expire,
    bool isPurchased = false,
    required int categoryId,
  }) async {
    try {
      final response = await _dioClient.post('$_baseUrl/items', data: {
        'list_id': listId,
        'item_name': itemName,
        'quantity': quantity,
        'unit': unit,
        'expire': expire.toIso8601String(),
        'is_purchased': isPurchased,
        'category_id': categoryId,
      });

      return ShoppingItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể thêm sản phẩm: ${e.toString()}');
    }
  }

  // Cập nhật một item
  Future<ShoppingItem> updateItemInList(int listId, ShoppingItem item) async {
    try {
      final response = await _dioClient.put(
        '$_baseUrl/$listId/items/${item.id}',
        data: {
          'item_name': item.itemName,
          'quantity': item.quantity,
          'unit': item.unit,
          'is_purchased': item.isPurchased,
        },
      );
      return ShoppingItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể cập nhật sản phẩm: ${e.toString()}');
    }
  }

  Future<bool> changePurchaseStatus(int itemId) async {
    try {
      final response = await _dioClient.path('$_baseUrl/items/$itemId');

      if (response.statusCode == 200) {
        // Nếu server trả về thành công, bạn có thể kiểm tra thêm nếu muốn
        final data = response.data;
        print("Cập nhật trạng thái thành công: ${data['item']}");
        return true;
      } else {
        throw Exception('Yêu cầu thất bại với status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể cập nhật sản phẩm: ${e.toString()}');
    }
  }

  // Xóa một item
  Future<void> deleteItemFromList(int itemId) async {
    try {
      await _dioClient.delete('$_baseUrl/items/$itemId');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi xoá thực phẩm này, hãy thử lại.');
    }
  }

  Future<void> deleteShoppingList(int listId) async {
    try {
      await _dioClient.delete('$_baseUrl/$listId');
    } catch (e) {
      throw Exception('Không thể cập nhật danh sách: ${e.toString()}');
    }
  }

  Future<void> updateShoppingList(int listId, Map<String, dynamic> data) async {
    try {
      await _dioClient.put('$_baseUrl/$listId', data: data);
    } catch (e) {
      throw Exception('Không thể cập nhật danh sách: ${e.toString()}');
    }
  }
}
