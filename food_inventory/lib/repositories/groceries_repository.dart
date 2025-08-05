import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:stock_mate/models/grocery.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../core/network/dio_client.dart';

class GroceriesRepository {
  final DioClient _dioClient;

  GroceriesRepository(this._dioClient);

  final baseUrl = "/groceries";

  // Lấy danh sách sản phẩm
  Future<List<Grocery>> getGroceries({String? storageId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (storageId != null) queryParams['storage_id'] = storageId;

      final response =
          await _dioClient.get(baseUrl, queryParameters: queryParams);

      // Kiểm tra dữ liệu trả về
      if (response.data is! List) {
        throw Exception('Dữ liệu trả về không đúng định dạng danh sách.');
      }

      final List<dynamic> rawList = response.data ?? [];
      return rawList.map((e) => Grocery.fromJson(e)).toList();
    } on DioException catch (e) {
      // Xử lý lỗi cụ thể từ Dio
      if (e.response != null) {
        throw Exception('Vui lòng kiểm tra lại kết nối');
      } else {
        throw Exception('Lỗi kết nối đến máy chủ, thử lại sau');
      }
    } catch (e) {
      throw Exception('Đã có lỗi xảy ra khi cập nhật danh sách');
    }
  }

  Future<List<Grocery>> getExpiredGroceries({String? storageId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (storageId != null) queryParams['storage_id'] = storageId;

      final response = await _dioClient.get("$baseUrl/expired",
          queryParameters: queryParams);

      // Kiểm tra dữ liệu trả về
      if (response.data is! List) {
        throw Exception('Dữ liệu trả về không đúng định dạng danh sách.');
      }

      final List<dynamic> rawList = response.data ?? [];
      return rawList.map((e) => Grocery.fromJson(e)).toList();
    } on DioException catch (e) {
      // Xử lý lỗi cụ thể từ Dio
      if (e.response != null) {
        throw Exception('Vui lòng kiểm tra lại kết nối');
      } else {
        throw Exception('Lỗi kết nối đến máy chủ, thử lại sau');
      }
    } catch (e) {
      throw Exception('Đã có lỗi xảy ra khi cập nhật danh sách');
    }
  }

  Future<List<Grocery>> getExpiringGroceries({String? storageId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (storageId != null) queryParams['storage_id'] = storageId;

      final response = await _dioClient.get("$baseUrl/expiring",
          queryParameters: queryParams);

      // Kiểm tra dữ liệu trả về
      if (response.data is! List) {
        throw Exception('Dữ liệu trả về không đúng định dạng danh sách.');
      }

      final List<dynamic> rawList = response.data ?? [];
      return rawList.map((e) => Grocery.fromJson(e)).toList();
    } on DioException catch (e) {
      // Xử lý lỗi cụ thể từ Dio
      if (e.response != null) {
        throw Exception('Vui lòng kiểm tra lại kết nối');
      } else {
        throw Exception('Lỗi kết nối đến máy chủ, thử lại sau');
      }
    } catch (e) {
      throw Exception('Đã có lỗi xảy ra khi cập nhật danh sách');
    }
  }

  // Thêm sản phẩm mới
  Future<Grocery> createGrocery(Grocery grocery, File? imageFile) async {
    try {
      final mimeType =
          imageFile != null ? lookupMimeType(imageFile.path) : null;
      final formData = FormData.fromMap({
        "storage_id": grocery.storageId,
        "name": grocery.name,
        "category_id": grocery.categoryId,
        "quantity": grocery.quantity,
        "unit": grocery.unit,
        "import_date": grocery.importDate?.toIso8601String(),
        "expire_date": grocery.expireDate?.toIso8601String(),
        "note": grocery.note,
        "status": grocery.status,
        "position_id": grocery.positionId,
        if (imageFile != null && mimeType != null)
          "image": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
            contentType: MediaType.parse(mimeType),
          ),
      });
      final response = await _dioClient.post(baseUrl, data: formData);
      return Grocery.fromJson(response.data);
    } catch (e) {
      print('Không thể thêm sản phẩm: ${e.toString()}');
      throw Exception('Không thể thêm sản phẩm: ${e.toString()}');
    }
  }

  // Cập nhật sản phẩm
  Future<Grocery> updateGrocery(Grocery product, File? imageFile) async {
    try {
      final mimeType =
          imageFile != null ? lookupMimeType(imageFile.path) : null;

      final formData = FormData.fromMap({
        "storage_id": product.storageId,
        "name": product.name,
        "category_id": product.categoryId,
        "quantity": product.quantity,
        "unit": product.unit,
        "import_date": product.importDate?.toIso8601String(),
        "expire_date": product.expireDate?.toIso8601String(),
        "note": product.note,
        "status": product.status,
        "position_id": product.positionId,
        if (imageFile != null && mimeType != null)
          "image": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
            contentType: MediaType.parse(mimeType),
          ),
      });

      final response = await _dioClient.put(
        '$baseUrl/${product.id}',
        data: formData,
      );

      return Grocery.fromJson(response.data);
    } catch (e) {
      print('Không thể cập nhật sản phẩm: ${e.toString()}');
      throw Exception('Không thể cập nhật sản phẩm: ${e.toString()}');
    }
  }

  // Xóa sản phẩm
  Future<void> deleteGrocery(int productId) async {
    try {
      await _dioClient.delete('$baseUrl/$productId');
    } catch (e) {
      throw Exception('Không thể xóa sản phẩm: ${e.toString()}');
    }
  }

  Future<void> deleteMultipleGroceries(List<int> ids) async {
    try {
      await _dioClient.delete(
        '$baseUrl/multiple',
        data: {
          'ids': ids,
        },
      );
    } catch (e) {
      throw Exception('Không thể xóa nhiều sản phẩm: ${e.toString()}');
    }
  }

  // Tìm kiếm sản phẩm
  Future<List<Grocery>> searchGroceries(String query,
      {String? storageId}) async {
    try {
      final queryParams = <String, dynamic>{'q': query};
      if (storageId != null) queryParams['storage_id'] = storageId;

      final response =
          await _dioClient.get('$baseUrl/search', queryParameters: queryParams);

      final List<dynamic> data = response.data['products'] ?? [];
      return data.map((json) => Grocery.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tìm kiếm sản phẩm: ${e.toString()}');
    }
  }
}
