import 'package:equatable/equatable.dart';

enum IngredientStatus { conDung, hetHan, daDung, huy }

class Ingredient extends Equatable {
  final String id;
  final String storageId;
  final String name;
  final String? categoryId;
  final int quantity;
  final String? unit;
  final DateTime? importDate;
  final DateTime? expireDate;
  final String? note;
  final IngredientStatus status;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ingredient({
    required this.id,
    required this.storageId,
    required this.name,
    this.categoryId,
    required this.quantity,
    this.unit,
    this.importDate,
    this.expireDate,
    this.note,
    required this.status,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor từ JSON
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? '',
      storageId: json['storage_id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['category_id'],
      quantity: json['quantity'] ?? 0,
      unit: json['unit'],
      importDate: json['import_date'] != null
          ? DateTime.parse(json['import_date'])
          : null,
      expireDate: json['expire_date'] != null
          ? DateTime.parse(json['expire_date'])
          : null,
      note: json['note'],
      status: _parseStatus(json['status']),
      imagePath: json['image_path'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Chuyển object về JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storage_id': storageId,
      'name': name,
      'category_id': categoryId,
      'quantity': quantity,
      'unit': unit,
      'import_date': importDate?.toIso8601String(),
      'expire_date': expireDate?.toIso8601String(),
      'note': note,
      'status': _statusToString(status),
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static IngredientStatus _parseStatus(String? status) {
    switch (status) {
      case 'con_dung':
        return IngredientStatus.conDung;
      case 'het_han':
        return IngredientStatus.hetHan;
      case 'da_dung':
        return IngredientStatus.daDung;
      case 'huy':
        return IngredientStatus.huy;
      default:
        return IngredientStatus.conDung;
    }
  }

  static String _statusToString(IngredientStatus status) {
    switch (status) {
      case IngredientStatus.conDung:
        return 'con_dung';
      case IngredientStatus.hetHan:
        return 'het_han';
      case IngredientStatus.daDung:
        return 'da_dung';
      case IngredientStatus.huy:
        return 'huy';
    }
  }

  @override
  List<Object?> get props => [
        id,
        storageId,
        name,
        categoryId,
        quantity,
        unit,
        importDate,
        expireDate,
        note,
        status,
        imagePath,
        createdAt,
        updatedAt,
      ];
}
