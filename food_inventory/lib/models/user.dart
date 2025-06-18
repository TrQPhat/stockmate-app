import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String userId;
  final String email;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;
  final String? gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.userId,
    required this.email,
    this.phone,
    this.fullName,
    this.avatarUrl,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor từ JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? -1,
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      gender: json['gender'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now()),
    );
  }

  // Chuyển object về JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        email,
        phone,
        fullName,
        avatarUrl,
        gender,
        createdAt,
        updatedAt,
      ];
}
