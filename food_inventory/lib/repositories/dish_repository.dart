import 'dart:convert';

import 'package:dio/dio.dart';
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
    final prefs = getIt<SharedPreferences>();
    final storageId = prefs.getInt(AppConfig.storageIdKey);
    final userId = prefs.getInt(AppConfig.userIdKey);
    if (storageId == null || userId == null) {
      throw Exception(
          'Không tìm thấy kho hàng hoặc người dùng. Vui lòng chọn kho hàng.');
    }
    try {
      final response = await _dioClient.get("$baseUrl/$storageId/$userId");

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

      final prefs = getIt<SharedPreferences>();
      final storageId = prefs.getInt(AppConfig.storageIdKey) ?? 0;
      if (storageId == 0) {
        throw Exception('Không tìm thấy kho hàng. Vui lòng chọn kho hàng.');
      }

      // Map sang Dish
      final dishes = rawList.map((e) {
        return Dish(
          name: e['name'] ?? '',
          description: e['description'] ?? '',
          instructions: e['instructions'] ?? '',
          imageUrl: e['image_url'] ?? '',
          cookTimeMinutes: e['cook_time_minutes'] ?? 0,
          isAISuggested: true,
          storageId: storageId,
        );
      }).toList();

      // ✅ Lưu danh sách vào SharedPreferences
      final dishesJson = jsonEncode(dishes.map((d) => d.toJson()).toList());
      await prefs.setString(AppConfig.suggestedDishesKey, dishesJson);

      // ✅ Lưu thời gian gợi ý gần nhất
      await prefs.setString(
          AppConfig.lastSuggestedDishKey, DateTime.now().toIso8601String());

      return dishes;
    } catch (e) {
      print('Lỗi khi parse JSON món ăn từ Gemini: $e');
      throw Exception('Không thể phân tích kết quả từ Gemini.');
    }
  }

  Future<List<Dish>> getSuggestedDishes() async {
    final prefs = getIt<SharedPreferences>();

    final lastSuggestedStr = prefs.getString(AppConfig.lastSuggestedDishKey);
    final now = DateTime.now();

    if (lastSuggestedStr != null) {
      try {
        final lastSuggested = DateTime.parse(lastSuggestedStr);

        // So sánh ngày (bỏ phần giờ)
        final isSameDay = lastSuggested.year == now.year &&
            lastSuggested.month == now.month &&
            lastSuggested.day == now.day;

        if (isSameDay) {
          // ✅ Đọc danh sách món ăn đã lưu
          final jsonStr = prefs.getString(AppConfig.suggestedDishesKey);
          if (jsonStr != null) {
            final List<dynamic> jsonList = jsonDecode(jsonStr);
            final dishes = jsonList.map((e) {
              final dish = Dish.fromJson(e);
              return dish.copyWith(isAISuggested: true);
            }).toList();
            return dishes;
          }
        }
      } catch (e) {
        print('Lỗi khi đọc dữ liệu local suggested dishes: $e');
      }
    }

    // Nếu không có dữ liệu đã lưu hoặc ngày không trùng, gọi API Gemini
    List<Grocery> availableFoods = await getExpiringGroceries();
    print("Danh sách thực phẩm: ${jsonEncode(availableFoods)}");

    String prompt;

    if (availableFoods.isNotEmpty) {
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

      // 2. Prompt khi có nguyên liệu
      prompt = """
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
    } else {
      // 3. Prompt fallback khi không có thực phẩm
      prompt = """
      Bạn là một đầu bếp AI tài năng.
      Nhiệm vụ của bạn là đề xuất 7-10 món ăn ngon, dễ làm và phù hợp với thời tiết hiện tại.
      Mỗi món ăn bạn đề xuất phải được trả về dưới dạng một đối tượng JSON. Các món ăn nên sử dụng đa dạng và nhiều loại thực phẩm nhất có thể từ danh sách các nguyên liệu phổ biến, dễ tìm.
      Định dạng JSON cho mỗi món ăn phải như sau:

        ```json
        {
            "name": "",
            "description": "",
            "instructions": "",
            "cook_time_minutes": 0,
            "image_url": ""
        }
        Và toàn bộ phản hồi phải là một MẢNG JSON chứa 7-10 món ăn, ví dụ:
        [
          {{ ... }},
          {{ ... }},
          ...
        ]
        Không có văn bản thừa bên ngoài JSON. Chỉ trả về mảng JSON.
      """;
    }

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

  Future<Dish> updateDish(Dish dish) async {
    try {
      final response = await _dioClient.put(
        "$baseUrl/${dish.id}",
        data: dish.toJson(),
      );

      return Dish.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Vui lòng kiểm tra lại kết nối');
      } else {
        throw Exception('Lỗi kết nối đến máy chủ, thử lại sau');
      }
    } catch (e) {
      throw Exception('Đã có lỗi xảy ra khi cập nhật món ăn');
    }
  }

  Future<void> deleteDish(int dishId) async {
    try {
      await _dioClient.delete("$baseUrl/$dishId");
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Vui lòng kiểm tra lại kết nối');
      } else {
        throw Exception('Lỗi kết nối đến máy chủ, thử lại sau');
      }
    } catch (e) {
      throw Exception('Đã có lỗi xảy ra khi xoá món ăn');
    }
  }

  Future<Dish> createDish(Dish dish) async {
    try {
      final response = await _dioClient.post(
        baseUrl,
        data: dish.toJson(),
      );

      return Dish.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Vui lòng kiểm tra lại kết nối');
      } else {
        throw Exception('Lỗi kết nối đến máy chủ, thử lại sau');
      }
    } catch (e) {
      throw Exception('Đã có lỗi xảy ra khi thêm món ăn');
    }
  }

  Future<bool> toggleFavoriteDish({
    required int userId,
    required int dishId,
  }) async {
    try {
      final response = await _dioClient.post(
        '$baseUrl/favorite',
        data: {
          'user_id': userId,
          'dish_id': dishId,
        },
      );

      // Trả về kết quả is_favorited từ server
      return response.data['is_favorited'] as bool;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Vui lòng kiểm tra lại kết nối');
      } else {
        throw Exception('Lỗi kết nối đến máy chủ, thử lại sau');
      }
    } catch (e) {
      throw Exception('Đã có lỗi xảy ra khi xử lý yêu thích món ăn');
    }
  }
}
