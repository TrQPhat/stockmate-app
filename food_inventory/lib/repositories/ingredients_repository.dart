import 'dart:convert';

import 'package:stock_mate/core/config/app_config.dart';

import '../core/network/dio_client.dart';
import '../models/ingredient.dart';
import 'package:stock_mate/models/category.dart';

class IngredientsRepository {
  final DioClient _dioClient;

  IngredientsRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/products";

  // Lấy danh sách sản phẩm
  Future<List<Ingredient>> getIngredients({String? storageId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (storageId != null) queryParams['storage_id'] = storageId;

      final response =
          await _dioClient.get(baseUrl, queryParameters: queryParams);
      final List<dynamic> rawList = response.data ?? [];

      return rawList.map((e) => Ingredient.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách sản phẩm: ${e.toString()}');
    }
  }

  // Thêm sản phẩm mới
  Future<Ingredient> createIngredient(Ingredient product) async {
    try {
      final response =
          await _dioClient.post('/products', data: product.toJson());
      return Ingredient.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể thêm sản phẩm: ${e.toString()}');
    }
  }

  // Cập nhật sản phẩm
  Future<Ingredient> updateIngredient(Ingredient product) async {
    try {
      final response = await _dioClient.put('/products/${product.id}',
          data: product.toJson());
      return Ingredient.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể cập nhật sản phẩm: ${e.toString()}');
    }
  }

  // Xóa sản phẩm
  Future<void> deleteIngredient(String productId) async {
    try {
      await _dioClient.delete('/products/$productId');
    } catch (e) {
      throw Exception('Không thể xóa sản phẩm: ${e.toString()}');
    }
  }

  // Tìm kiếm sản phẩm
  Future<List<Ingredient>> searchIngredients(String query,
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
