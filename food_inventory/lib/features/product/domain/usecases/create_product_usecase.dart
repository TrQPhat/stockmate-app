import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<Product> call(String storageId, Map<String, dynamic> data) {
    return repository.createProduct(storageId, data);
  }
}
