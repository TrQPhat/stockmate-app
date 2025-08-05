import 'package:stock_mate/core/config/app_config.dart';
import '../core/network/dio_client.dart';
import 'package:stock_mate/models/category.dart';

class CategoriesRepository {
  final DioClient _dioClient;

  CategoriesRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/categories";
  // Thêm danh mục mới
  Future<Category> addCategory(Category category) async {
    try {
      final response =
          await _dioClient.post('/categories', data: category.toJson());
      return Category.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể thêm danh mục: ${e.toString()}');
    }
  }

  // Sửa danh mục
  Future<Category> updateCategory(Category category) async {
    try {
      final response = await _dioClient.put('/categories/${category.id}',
          data: category.toJson());
      return Category.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể cập nhật danh mục: ${e.toString()}');
    }
  }

  // Xoá danh mục
  Future<void> deleteCategory(int categoryId) async {
    try {
      await _dioClient.delete('/categories/$categoryId');
    } catch (e) {
      throw Exception('Không thể xoá danh mục: ${e.toString()}');
    }
  }

  // Lấy danh sách danh mục
  Future<List<Category>> getCategories() async {
    try {
      final id = AppConfig.storageId();
      if (id == -1) {
        throw Exception('Không tồn tại mã kho "-1"');
      }

      final response = await _dioClient.get('/categories/$id');

      final List<dynamic> data = response.data ?? [];
      print("dữ liệu hiện tại: $data");
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách danh mục: ${e.toString()}');
    }
  }
}
