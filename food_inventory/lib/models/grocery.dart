import 'package:equatable/equatable.dart';

enum GroceryStatus { conDung, hetHan, daDung, huy }

extension GroceryStatusExtension on GroceryStatus {
  static GroceryStatus fromString(String? status) {
    switch (status) {
      case 'con_dung':
        return GroceryStatus.conDung;
      case 'het_han':
        return GroceryStatus.hetHan;
      case 'da_dung':
        return GroceryStatus.daDung;
      case 'huy':
        return GroceryStatus.huy;
      default:
        return GroceryStatus.conDung;
    }
  }

  String toShortString() {
    switch (this) {
      case GroceryStatus.conDung:
        return 'con_dung';
      case GroceryStatus.hetHan:
        return 'het_han';
      case GroceryStatus.daDung:
        return 'da_dung';
      case GroceryStatus.huy:
        return 'huy';
    }
  }

  String get label {
    switch (this) {
      case GroceryStatus.conDung:
        return 'Còn dùng';
      case GroceryStatus.hetHan:
        return 'Hết hạn';
      case GroceryStatus.daDung:
        return 'Đã dùng';
      case GroceryStatus.huy:
        return 'Huỷ';
    }
  }
}

enum GroceryPosition {
  tuDong(1, 'Tủ đông'),
  nganMat(2, 'Ngăn mát'),
  benTrai(3, 'Bên trái'),
  benPhai(4, 'Bên phải');

  final int code;
  final String label;

  const GroceryPosition(this.code, this.label);

  static GroceryPosition? fromCode(int code) {
    try {
      return GroceryPosition.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return null;
    }
  }
}

class Grocery extends Equatable {
  final int id;
  final int storageId;
  final String name;
  final int? categoryId;
  final int quantity;
  final String? unit;
  final DateTime? importDate;
  final DateTime? expireDate;
  final String? note;
  final GroceryStatus status;
  final int? positionId;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Grocery({
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
    this.positionId,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Grocery.fromJson(Map<String, dynamic> json) {
    return Grocery(
      id: json['id'] ?? -1,
      storageId: json['storage_id'] ?? -1,
      name: json['name'] ?? '',
      categoryId: json['category_id'],
      quantity: json['quantity'] ?? 0,
      unit: json['unit'],
      importDate: json['import_date'] != null
          ? DateTime.tryParse(json['import_date'])
          : null,
      expireDate: json['expire_date'] != null
          ? DateTime.tryParse(json['expire_date'])
          : null,
      note: json['note'],
      status: GroceryStatusExtension.fromString(json['status']),
      positionId: json['position_id'] != null
          ? int.tryParse(json['position_id'].toString())
          : null,
      imagePath: json['image_path'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

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
      'status': status.toShortString(),
      'position_id': positionId,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
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
        positionId,
        imagePath,
        createdAt,
        updatedAt,
      ];
}
