import 'package:stock_mate/models/user_tam.dart';

import '../core/network/dio_client.dart';

class UserMemberRepository {
  final DioClient _dioClient;

  UserMemberRepository(this._dioClient);

  // Lấy danh sách thành viên trong kho
  Future<List<UserMember>> getStorageMembers(String storageId) async {
    try {
      final response = await _dioClient.get('/storages/$storageId/members');

      final List<dynamic> data = response.data['members'] ?? [];
      return data.map((json) => UserMember.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách thành viên: ${e.toString()}');
    }
  }

  // Thêm thành viên vào kho
  Future<UserMember> inviteUserToStorage(
      String storageId, String email, MemberRole role) async {
    try {
      final response =
          await _dioClient.post('/storages/$storageId/members/invite', data: {
        'email': email,
        'role': _roleToString(role),
      });

      return UserMember.fromJson(response.data['member']);
    } catch (e) {
      throw Exception('Không thể mời thành viên: ${e.toString()}');
    }
  }

  // Thay đổi quyền của thành viên
  Future<UserMember> updateMemberRole(
      String storageId, String memberId, MemberRole role) async {
    try {
      final response =
          await _dioClient.put('/storages/$storageId/members/$memberId', data: {
        'role': _roleToString(role),
      });

      return UserMember.fromJson(response.data['member']);
    } catch (e) {
      throw Exception('Không thể cập nhật quyền thành viên: ${e.toString()}');
    }
  }

  // Xóa thành viên khỏi kho
  Future<void> removeMemberFromStorage(
      String storageId, String memberId) async {
    try {
      await _dioClient.delete('/storages/$storageId/members/$memberId');
    } catch (e) {
      throw Exception('Không thể xóa thành viên: ${e.toString()}');
    }
  }

  // Lấy mã mời của kho
  Future<String> getStorageInviteCode(String storageId) async {
    try {
      final response = await _dioClient.get('/storages/$storageId/invite-code');
      return response.data['invite_code'] ?? '';
    } catch (e) {
      throw Exception('Không thể lấy mã mời: ${e.toString()}');
    }
  }

  // Tạo mã mời mới
  Future<String> generateNewInviteCode(String storageId) async {
    try {
      final response =
          await _dioClient.post('/storages/$storageId/invite-code');
      return response.data['invite_code'] ?? '';
    } catch (e) {
      throw Exception('Không thể tạo mã mời mới: ${e.toString()}');
    }
  }

  // Helper method to convert MemberRole to string
  String _roleToString(MemberRole role) {
    switch (role) {
      case MemberRole.owner:
        return 'owner';
      case MemberRole.editor:
        return 'editor';
      case MemberRole.viewer:
        return 'viewer';
    }
  }
}
