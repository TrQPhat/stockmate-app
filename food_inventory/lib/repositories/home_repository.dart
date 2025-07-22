import 'package:stock_mate/core/config/app_config.dart';
import '../core/network/dio_client.dart';
import '../models/home_stats.dart';

class HomeRepository {
  final DioClient _dioClient;

  HomeRepository(this._dioClient);

  final baseUrl = "${AppConfig.baseUrl}/home";

  // Lấy thống kê cho trang chủ
  Future<HomeStats> getHomeStats(int storageId) async {
    try {
      final response = await _dioClient.get('$baseUrl/stats/$storageId');
      final data = response.data;

      return HomeStats.fromJson(data);
    } catch (e) {
      throw Exception('Không thể tải dữ liệu thống kê: ${e.toString()}');
    }
  }
}
