import 'package:equatable/equatable.dart';

enum MemberRole { owner, editor, viewer }

class UserMember extends Equatable {
  final String id;
  final String userId;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final MemberRole role;
  final DateTime joinedAt;

  const UserMember({
    required this.id,
    required this.userId,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
  });

  // Factory constructor từ JSON
  factory UserMember.fromJson(Map<String, dynamic> json) {
    return UserMember(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      role: _parseRole(json['role']),
      joinedAt:
          DateTime.parse(json['joined_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Chuyển object về JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
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
  List<Object?> get props =>
      [id, userId, email, fullName, avatarUrl, role, joinedAt];
}
