import 'package:stock_mate/core/config/app_config.dart';
import '../core/network/dio_client.dart';
import 'package:stock_mate/models/position.dart';

class PositionRepository {
  final DioClient _dioClient;

  PositionRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/positions";

  // Thêm vị trí mới
  Future<Position> addPosition(Position position) async {
    try {
      final response =
          await _dioClient.post('/positions', data: position.toJson());
      return Position.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể thêm vị trí: ${e.toString()}');
    }
  }

  // Sửa vị trí
  Future<Position> updatePosition(Position position) async {
    try {
      final response = await _dioClient.put('/positions/${position.id}',
          data: position.toJson());
      return Position.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể cập nhật vị trí: ${e.toString()}');
    }
  }

  // Xoá vị trí
  Future<void> deletePosition(int positionId) async {
    try {
      await _dioClient.delete('/positions/$positionId');
    } catch (e) {
      throw Exception('Không thể xoá vị trí: ${e.toString()}');
    }
  }

  // Lấy danh sách danh mục
  Future<List<Position>> getPosition() async {
    try {
      final id = AppConfig.storageId();
      if (id == -1) {
        throw Exception('Không tồn tại mã kho "-1"');
      }
      final response = await _dioClient.get('/positions/$id');

      final List<dynamic> data = response.data ?? [];

      return data.map((json) => Position.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách danh mục: ${e.toString()}');
    }
  }
}
