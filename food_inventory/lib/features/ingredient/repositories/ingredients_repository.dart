import 'package:stock_mate/core/config/app_config.dart';

import '../../../core/network/dio_client.dart';
import '../models/ingredient.dart';
import '../models/category.dart';

class ProductsRepository {
  final DioClient _dioClient;

  ProductsRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/products";

  // Lấy danh sách sản phẩm
  Future<List<Ingredient>> getProducts(
      {String? storageId, String? categoryId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (storageId != null) queryParams['storage_id'] = storageId;
      if (categoryId != null) queryParams['category_id'] = categoryId;

      final response =
          await _dioClient.get(baseUrl, queryParameters: queryParams);

      final List<dynamic> rawList = response.data ?? [];

      return rawList.map((e) => Ingredient.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách sản phẩm: ${e.toString()}');
    }
  }

  // Thêm sản phẩm mới
  Future<Ingredient> createProduct(Ingredient product) async {
    try {
      final response =
          await _dioClient.post('/products', data: product.toJson());
      return Ingredient.fromJson(response.data['product']);
    } catch (e) {
      throw Exception('Không thể thêm sản phẩm: ${e.toString()}');
    }
  }

  // Cập nhật sản phẩm
  Future<Ingredient> updateProduct(Ingredient product) async {
    try {
      final response = await _dioClient.put('/products/${product.id}',
          data: product.toJson());
      return Ingredient.fromJson(response.data['product']);
    } catch (e) {
      throw Exception('Không thể cập nhật sản phẩm: ${e.toString()}');
    }
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String productId) async {
    try {
      await _dioClient.delete('/products/$productId');
    } catch (e) {
      throw Exception('Không thể xóa sản phẩm: ${e.toString()}');
    }
  }

  // Lấy danh sách danh mục
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dioClient.get('/categories');

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách danh mục: ${e.toString()}');
    }
  }

  // Tìm kiếm sản phẩm
  Future<List<Ingredient>> searchProducts(String query,
      {String? storageId}) async {
    try {
      final queryParams = <String, dynamic>{'q': query};
      if (storageId != null) queryParams['storage_id'] = storageId;

      final response = await _dioClient.get('/products/search',
          queryParameters: queryParams);

      final List<dynamic> data = response.data['products'] ?? [];
      return data.map((json) => Ingredient.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tìm kiếm sản phẩm: ${e.toString()}');
    }
  }
}
