import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Product>> getProducts(String storageId) async {
    final result = await remoteDataSource.getProducts(storageId);
    return result;
  }

  @override
  Future<Product> createProduct(String storageId, Map<String, dynamic> data) async {
    final result = await remoteDataSource.createProduct(storageId, data);
    return result;
  }

  @override
  Future<Product> getProduct(String id) async {
    final result = await remoteDataSource.getProduct(id);
    return result;
  }

  @override
  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    final result = await remoteDataSource.updateProduct(id, data);
    return result;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await remoteDataSource.deleteProduct(id);
  }

  @override
  Future<void> useProduct(String id, int quantity, String? note) async {
    await remoteDataSource.useProduct(id, quantity, note);
  }
}
