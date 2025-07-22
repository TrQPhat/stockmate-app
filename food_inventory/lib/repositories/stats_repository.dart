import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/core/network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/waste_stats.dart'; // bạn cần tạo model này từ JSON trả về

class StatsRepository {
  final DioClient _dioClient;

  StatsRepository(this._dioClient);

  final String baseUrl = "${AppConfig.baseUrl}/stats";

  Future<WasteStats> getWasteStats() async {
    try {
      // Lấy storage_id từ SharedPreferences
      final prefs = getIt<SharedPreferences>();
      final storageId = prefs.getInt(AppConfig.storageIdKey);

      if (storageId == null) {
        throw Exception(
            "Không tìm thấy mã kho (storage_id) trong local storage");
      }

      final response = await _dioClient.get('$baseUrl/waste/$storageId');
      final data = response.data;
      print("Waste Stats Data: $data"); // Debugging line
      return WasteStats.fromJson(data);
    } catch (e) {
      print("Error fetching waste stats: $e"); // Debugging line
      throw Exception('Không thể tải thống kê lãng phí: ${e.toString()}');
    }
  }
}
