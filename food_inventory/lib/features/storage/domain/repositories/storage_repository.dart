import '../entities/storage.dart';

abstract class StorageRepository {
  Future<List<Storage>> getStorages();
  Future<Storage> createStorage(String name);
  Future<Storage> joinStorage(String inviteCode);
  Future<Storage> getStorage(String id);
  Future<Storage> updateStorage(String id, String name);
  Future<void> deleteStorage(String id);
}
