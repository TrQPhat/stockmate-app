import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts(String storageId);
  Future<Product> createProduct(String storageId, Map<String, dynamic> data);
  Future<Product> getProduct(String id);
  Future<Product> updateProduct(String id, Map<String, dynamic> data);
  Future<void> deleteProduct(String id);
  Future<void> useProduct(String id, int quantity, String? note);
}
