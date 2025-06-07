import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final SupabaseClient _supabase;

  ProductRemoteDataSource(this._supabase);

  Future<List<ProductModel>> getProducts(String storageId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('storage_id', storageId)
          .order('created_at', ascending: false);

      return response.map((item) => ProductModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách sản phẩm: ${e.toString()}');
    }
  }

  Future<ProductModel> createProduct(String storageId, Map<String, dynamic> data) async {
    try {
      final productData = {
        'storage_id': storageId,
        ...data,
      };

      final response = await _supabase
          .from('products')
          .insert(productData)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi tạo sản phẩm: ${e.toString()}');
    }
  }

  Future<ProductModel> getProduct(String id) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', id)
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin sản phẩm: ${e.toString()}');
    }
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final updateData = {
        ...data,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('products')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật sản phẩm: ${e.toString()}');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Lỗi khi xóa sản phẩm: ${e.toString()}');
    }
  }

  Future<void> useProduct(String id, int quantity, String? note) async {
    try {
      // Lấy thông tin sản phẩm hiện tại
      final product = await getProduct(id);
      
      // Cập nhật số lượng
      final newQuantity = product.quantity - quantity;
      final newStatus = newQuantity <= 0 ? 'da_dung' : product.status.name;
      
      await updateProduct(id, {
        'quantity': newQuantity,
        'status': newStatus,
      });

      // Thêm log
      await _supabase.from('product_logs').insert({
        'product_id': id,
        'action': 'da_dung',
        'quantity': quantity,
        'note': note,
      });
    } catch (e) {
      throw Exception('Lỗi khi sử dụng sản phẩm: ${e.toString()}');
    }
  }
}
