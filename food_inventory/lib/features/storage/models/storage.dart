import 'package:equatable/equatable.dart';

class Storage extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;

  const Storage({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
  });

  // Factory constructor từ JSON
  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      ownerId: json['owner_id'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Chuyển object về JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [id, name, ownerId, createdAt];
}
