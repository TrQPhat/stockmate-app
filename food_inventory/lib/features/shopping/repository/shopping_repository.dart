import 'package:stock_mate/core/network/dio_client.dart';
import 'package:stock_mate/features/shopping/models/shopping_list.dart';
import 'package:stock_mate/features/shopping/models/shopping_list_item.dart';

class ShoppingRepository {
  final DioClient _dioClient;
  final String _baseUrl = '/shopping-lists'; // Base URL cho shopping API

  ShoppingRepository(this._dioClient);

  // Lấy tất cả danh sách mua sắm
  Future<List<ShoppingList>> getShoppingLists() async {
    try {
      final response = await _dioClient.get(_baseUrl);
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => ShoppingList.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách mua sắm: ${e.toString()}');
    }
  }

  // Lấy chi tiết một danh sách
  Future<ShoppingList> getShoppingListDetails(String listId) async {
    try {
      final response = await _dioClient.get('$_baseUrl/$listId');
      return ShoppingList.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải chi tiết danh sách: ${e.toString()}');
    }
  }

  // Tạo danh sách mới
  Future<ShoppingList> createShoppingList(
      String name, DateTime purchaseDate) async {
    try {
      final response = await _dioClient.post(_baseUrl, data: {
        'name': name,
        'purchase_date': purchaseDate
            .toIso8601String()
            .substring(0, 10), // Format YYYY-MM-DD
      });
      return ShoppingList.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tạo danh sách: ${e.toString()}');
    }
  }

  // Xóa danh sách
  Future<void> deleteShoppingList(String listId) async {
    try {
      await _dioClient.delete('$_baseUrl/$listId');
    } catch (e) {
      throw Exception('Không thể xóa danh sách: ${e.toString()}');
    }
  }

  // Thêm một item vào danh sách
  Future<ShoppingListItem> addItemToList({
    required String listId,
    required String itemName,
    required int quantity,
    String? unit,
    required double price,
  }) async {
    try {
      final response = await _dioClient.post('$_baseUrl/$listId/items', data: {
        'item_name': itemName,
        'quantity': quantity,
        'unit': unit,
        'price': price,
      });
      return ShoppingListItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể thêm sản phẩm: ${e.toString()}');
    }
  }

  // Cập nhật một item
  Future<ShoppingListItem> updateItemInList(
      String listId, ShoppingListItem item) async {
    try {
      final response = await _dioClient.put(
        '$_baseUrl/$listId/items/${item.id}',
        data: {
          'item_name': item.itemName,
          'quantity': item.quantity,
          'unit': item.unit,
          'price': item.price,
          'is_purchased': item.isPurchased,
        },
      );
      return ShoppingListItem.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể cập nhật sản phẩm: ${e.toString()}');
    }
  }

  // Xóa một item
  Future<void> deleteItemFromList(String listId, String itemId) async {
    try {
      await _dioClient.delete('$_baseUrl/$listId/items/$itemId');
    } catch (e) {
      throw Exception('Không thể xóa sản phẩm: ${e.toString()}');
    }
  }

// Cập nhật danh sách
  Future<ShoppingList> updateShoppingList(
      String listId, String name, DateTime purchaseDate) async {
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
}
