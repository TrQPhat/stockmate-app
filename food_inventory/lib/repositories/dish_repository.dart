import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/models/dish.dart';
import 'package:stock_mate/models/grocery.dart';
import '../core/network/dio_client.dart';

class DishesRepository {
  final DioClient _dioClient;

  DishesRepository(this._dioClient);

  final String baseUrl = "/dishes";

  // Lấy danh sách món ăn
  Future<List<Dish>> getDishes() async {
    final storageId = getIt<SharedPreferences>().getInt(AppConfig.storageIdKey);

    try {
      final response = await _dioClient.get("$baseUrl/$storageId");

      if (response.data is! List) {
        throw Exception('Dữ liệu trả về không đúng định dạng danh sách.');
      }

      final List<dynamic> rawList = response.data ?? [];
      return rawList.map((e) => Dish.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Vui lòng kiểm tra lại kết nối');
      } else {
        throw Exception('Lỗi kết nối đến máy chủ, thử lại sau');
      }
    } catch (e) {
      throw Exception('Đã có lỗi xảy ra khi tải danh sách món ăn');
    }
  }

  // Lấy danh sách thực phẩm sắp hết hạn (expire_date trong 3 ngày tới)
  Future<List<Grocery>> getExpiringGroceries() async {
    try {
      final response = await _dioClient.get('/groceries/expiring');
      if (response.data is! List) {
        throw Exception('Dữ liệu trả về không đúng định dạng danh sách.');
      }
      final List<dynamic> rawList = response.data ?? [];
      return rawList.map((e) => Grocery.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Vui lòng kiểm tra lại kết nối');
      } else {
        throw Exception('Lỗi kết nối đến máy chủ, thử lại sau');
      }
    } catch (e) {
      throw Exception(
          'Đã có lỗi xảy ra khi lấy danh sách thực phẩm sắp hết hạn');
    }
  }

  Future<List<Dish>> _parseGeminiDishResponse(
      Map<String, dynamic> responseData) async {
    try {
      final rawText =
          responseData['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (rawText == null || rawText.isEmpty) {
        throw Exception('Phản hồi từ Gemini không có nội dung.');
      }

      // Loại bỏ markdown code block nếu có
      String jsonString = rawText.trim();
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7); // Bỏ '```json\n'
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3); // Bỏ '```'
      }

      // Loại bỏ phần dư sau JSON nếu kết thúc bị thiếu
      final lastClosing = jsonString.lastIndexOf(']');
      if (lastClosing != -1) {
        jsonString = jsonString.substring(0, lastClosing + 1);
      }

      // Decode JSON
      final List<dynamic> rawList = json.decode(jsonString);

      // Map sang Dish
      return rawList.map((e) {
        return Dish(
          id: "0",
          name: e['name'] ?? '',
          description: e['description'] ?? '',
          instructions: e['instructions'] ?? '',
          imageUrl: e['image_url'] ?? '',
          cookTimeMinutes: e['cook_time_minutes'] ?? 0,
          isAISuggested: true,
          storageId: 19,
        );
      }).toList();
    } catch (e) {
      print('Lỗi khi parse JSON món ăn từ Gemini: $e');
      throw Exception('Không thể phân tích kết quả từ Gemini.');
    }
  }

  Future<List<Dish>> getSuggestedDishes() async {
    List<Grocery> availableFoods = await getExpiringGroceries();
    print("Danh sách thực phẩm: ${jsonEncode(availableFoods)}");

    // 1. Chuẩn bị dữ liệu đầu vào cho Prompt
    final List<String> formattedInputLines = [];
    for (var dish in availableFoods) {
      final name = dish.name;
      final quantity = dish.quantity;
      final unit = dish.unit;
      formattedInputLines.add('- Tên: $name, Số lượng: $quantity $unit');
    }
    final String foodsInputString = formattedInputLines.join('\n');
    print("TP: $foodsInputString");

    // 2. Xây dựng Prompt đầy đủ
    final String prompt = """
      Bạn là một đầu bếp AI sáng tạo và hiệu quả.
      Tôi sẽ cung cấp cho bạn một danh sách các loại thực phẩm tôi đang có.
      Nhiệm vụ của bạn là đề xuất 7-10 món ăn ngon, dễ làm, sử dụng tối đa các thực phẩm trong danh sách đã cho.
      Mỗi món ăn được đề xuất phải được trả về dưới dạng một đối tượng JSON.
      Nếu có nhiều cách kết hợp, hãy ưu tiên các món ăn sử dụng đa dạng và nhiều loại thực phẩm nhất có thể từ danh sách.

      Đối với "image_url", hãy cung cấp một URL hình ảnh giả định (placeholder) phù hợp với món ăn.

      Đây là cấu trúc JSON cho MỖI món ăn được đề xuất:
      ```json
      {
          "name": "",
          "description": "",
          "instructions": "",
          "cook_time_minutes": 0,
          "image_url": ""
      }
      Và đây là định dạng của MẢNG JSON bạn cần trả về. Đảm bảo toàn bộ phản hồi là JSON hợp lệ và không có văn bản thừa bên ngoài khối JSON:
      [
        {{ ... }},
        {{ ... }},
        // ... (tối đa 10 món)
      ]
      Dưới đây là danh sách các thực phẩm tôi đang có (Chỉ quan tâm Tên và Số lượng):
      $foodsInputString
      """;
    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 2048
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        }
      ]
    };

    try {
      final response = await _dioClient.post(
        AppConfig.geminiApiEndpoint,
        data: requestBody,
        queryParameters: {
          'key': AppConfig.geminiApiKey,
        },
        options: Options(
          extra: {'attachAuthToken': false},
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Phản hồi từ Gemini API qua Dio sẽ nằm trong response.data
      final Map<String, dynamic>? responseData = response.data;

      if (responseData == null) {
        return [];
      }
      return await _parseGeminiDishResponse(responseData);
    } catch (e) {
      return [];
    }
  }
}
