import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/storage_model.dart';

class StorageRemoteDataSource {
  final SupabaseClient _supabase;

  StorageRemoteDataSource(this._supabase);

  Future<List<StorageModel>> getStorages() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Lấy danh sách kho mà user có quyền truy cập
      final response = await _supabase
          .from('storages')
          .select('''
            *,
            storage_members!inner(user_id, role),
            products(count)
          ''')
          .eq('storage_members.user_id', userId);

      final List<StorageModel> storages = [];
      for (final item in response) {
        final productCount = item['products']?.length ?? 0;
        
        storages.add(StorageModel(
          id: item['id'],
          name: item['name'],
          ownerId: item['owner_id'],
          createdAt: DateTime.parse(item['created_at']),
          memberCount: 1, // Sẽ được tính sau
          productCount: productCount,
        ));
      }

      return storages;
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách kho: ${e.toString()}');
    }
  }

  Future<StorageModel> createStorage(String name) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Tạo kho mới
      final storageResponse = await _supabase
          .from('storages')
          .insert({
            'name': name,
            'owner_id': userId,
          })
          .select()
          .single();

      // Thêm owner vào storage_members
      await _supabase.from('storage_members').insert({
        'storage_id': storageResponse['id'],
        'user_id': userId,
        'role': 'owner',
      });

      return StorageModel(
        id: storageResponse['id'],
        name: storageResponse['name'],
        ownerId: storageResponse['owner_id'],
        createdAt: DateTime.parse(storageResponse['created_at']),
        memberCount: 1,
        productCount: 0,
      );
    } catch (e) {
      throw Exception('Lỗi khi tạo kho: ${e.toString()}');
    }
  }

  Future<StorageModel> joinStorage(String inviteCode) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Tìm kho theo invite code (giả sử invite code là storage ID)
      final storageResponse = await _supabase
          .from('storages')
          .select()
          .eq('id', inviteCode)
          .single();

      // Kiểm tra xem user đã là thành viên chưa
      final existingMember = await _supabase
          .from('storage_members')
          .select()
          .eq('storage_id', inviteCode)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        throw Exception('Bạn đã là thành viên của kho này');
      }

      // Thêm user vào storage_members
      await _supabase.from('storage_members').insert({
        'storage_id': inviteCode,
        'user_id': userId,
        'role': 'viewer',
      });

      return StorageModel(
        id: storageResponse['id'],
        name: storageResponse['name'],
        ownerId: storageResponse['owner_id'],
        createdAt: DateTime.parse(storageResponse['created_at']),
        memberCount: 1,
        productCount: 0,
      );
    } catch (e) {
      throw Exception('Lỗi khi tham gia kho: ${e.toString()}');
    }
  }

  Future<StorageModel> getStorage(String id) async {
    try {
      final response = await _supabase
          .from('storages')
          .select('''
            *,
            storage_members(count),
            products(count)
          ''')
          .eq('id', id)
          .single();

      final memberCount = response['storage_members']?.length ?? 0;
      final productCount = response['products']?.length ?? 0;

      return StorageModel(
        id: response['id'],
        name: response['name'],
        ownerId: response['owner_id'],
        createdAt: DateTime.parse(response['created_at']),
        memberCount: memberCount,
        productCount: productCount,
      );
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin kho: ${e.toString()}');
    }
  }
}
