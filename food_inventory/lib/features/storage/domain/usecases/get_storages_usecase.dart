import '../entities/storage.dart';
import '../repositories/storage_repository.dart';

class GetStoragesUseCase {
  final StorageRepository repository;

  GetStoragesUseCase(this.repository);

  Future<List<Storage>> call() {
    return repository.getStorages();
  }
}
