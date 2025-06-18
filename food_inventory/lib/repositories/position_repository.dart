import 'package:stock_mate/core/config/app_config.dart';
import '../core/network/dio_client.dart';
import 'package:stock_mate/models/position.dart';

class PositionRepository {
  final DioClient _dioClient;

  PositionRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/positions";

  // Lấy danh sách danh mục
  Future<List<Position>> getPosition() async {
    try {
      final response = await _dioClient.get('/positions');

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => Position.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách danh mục: ${e.toString()}');
    }
  }
}
