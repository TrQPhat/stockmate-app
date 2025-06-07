import '../../domain/entities/storage.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/storage_remote_datasource.dart';

class StorageRepositoryImpl implements StorageRepository {
  final StorageRemoteDataSource remoteDataSource;

  StorageRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Storage>> getStorages() async {
    final result = await remoteDataSource.getStorages();
    return result;
  }

  @override
  Future<Storage> createStorage(String name) async {
    final result = await remoteDataSource.createStorage(name);
    return result;
  }

  @override
  Future<Storage> joinStorage(String inviteCode) async {
    final result = await remoteDataSource.joinStorage(inviteCode);
    return result;
  }

  @override
  Future<Storage> getStorage(String id) async {
    final result = await remoteDataSource.getStorage(id);
    return result;
  }

  @override
  Future<Storage> updateStorage(String id, String name) async {
    // TODO: Implement update storage
    throw UnimplementedError();
  }

  @override
  Future<void> deleteStorage(String id) async {
    // TODO: Implement delete storage
    throw UnimplementedError();
  }
}
