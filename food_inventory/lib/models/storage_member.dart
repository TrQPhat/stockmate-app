import 'package:equatable/equatable.dart';

enum MemberRole { owner, editor, viewer }

class StorageMember extends Equatable {
  final String id;
  final int storageId;
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;

  const StorageMember({
    required this.id,
    required this.storageId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  // Factory constructor từ JSON
  factory StorageMember.fromJson(Map<String, dynamic> json) {
    return StorageMember(
      id: json['id'] ?? '',
      storageId: json['storage_id'] ?? '',
      userId: json['user_id'] ?? '',
      role: _parseRole(json['role']),
      joinedAt:
          DateTime.parse(json['joined_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Chuyển object về JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storage_id': storageId,
      'user_id': userId,
      'role': _roleToString(role),
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  static MemberRole _parseRole(String? role) {
    switch (role) {
      case 'owner':
        return MemberRole.owner;
      case 'editor':
        return MemberRole.editor;
      case 'viewer':
        return MemberRole.viewer;
      default:
        return MemberRole.viewer;
    }
  }

  static String _roleToString(MemberRole role) {
    switch (role) {
      case MemberRole.owner:
        return 'owner';
      case MemberRole.editor:
        return 'editor';
      case MemberRole.viewer:
        return 'viewer';
    }
  }

  @override
  List<Object> get props => [id, storageId, userId, role, joinedAt];
}
