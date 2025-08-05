import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int? storageId;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.storageId,
  });

  // Factory constructor từ JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? -1,
      name: json['name'] ?? '',
      description: json['description'],
      storageId: json['storage_id'],
    );
  }

  // Chuyển object về JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'storage_id': storageId,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    int? storageId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      storageId: storageId ?? this.storageId,
    );
  }

  @override
  List<Object?> get props => [id, name, description, storageId];
}
