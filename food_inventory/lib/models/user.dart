import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;
  final String? gender;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? role;
  final DateTime? joinedAt;

  const User({
    required this.id,
    required this.email,
    this.phone,
    this.fullName,
    this.avatarUrl,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
    this.role,
    this.joinedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'] ?? '') ?? -1,
      email: json['email'] ?? '',
      phone: json['phone'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      gender: json['gender'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      role: json['role'],
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'role': role,
      'joined_at': joinedAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? userId,
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? role,
    DateTime? joinedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        fullName,
        avatarUrl,
        gender,
        createdAt,
        updatedAt,
        role,
        joinedAt,
      ];
}
