import '../entities/storage.dart';
import '../repositories/storage_repository.dart';

class CreateStorageUseCase {
  final StorageRepository repository;

  CreateStorageUseCase(this.repository);

  Future<Storage> call(String name) {
    return repository.createStorage(name);
  }
}
