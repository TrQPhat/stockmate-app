import 'package:stock_mate/core/config/app_config.dart';
import '../core/network/dio_client.dart';
import 'package:stock_mate/models/category.dart';

class CategoriesRepository {
  final DioClient _dioClient;

  CategoriesRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/grocery";

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
}
