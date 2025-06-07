import '../entities/storage.dart';
import '../repositories/storage_repository.dart';

class JoinStorageUseCase {
  final StorageRepository repository;

  JoinStorageUseCase(this.repository);

  Future<Storage> call(String inviteCode) {
    return repository.joinStorage(inviteCode);
  }
}
