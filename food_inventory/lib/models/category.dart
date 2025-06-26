import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  // Factory constructor từ JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? -1,
      name: json['name'] ?? '',
      description: json['description'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Chuyển object về JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, description, createdAt];
}
