import 'package:stock_mate/core/network/dio_client.dart';

import '../models/recipe.dart';

class RecipeRepository {
  final DioClient _dioClient;
  final String _baseUrl = '/recipes'; // Dựa trên RecipeRouters.js

  RecipeRepository(this._dioClient);

  Future<List<Recipe>> getAllRecipes() async {
    try {
      final response = await _dioClient.get(_baseUrl);
      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách công thức: ${e.toString()}');
    }
  }

  Future<Recipe> getRecipeById(String id) async {
    try {
      final response = await _dioClient.get('$_baseUrl/$id');
      return Recipe.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải chi tiết công thức: ${e.toString()}');
    }
  }

  Future<Recipe> createRecipe(Map<String, dynamic> recipeData) async {
    try {
      final response = await _dioClient.post(_baseUrl, data: recipeData);
      return Recipe.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tạo công thức: ${e.toString()}');
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await _dioClient.delete('$_baseUrl/$id');
    } catch (e) {
      throw Exception('Không thể xóa công thức: ${e.toString()}');
    }
  }
}
