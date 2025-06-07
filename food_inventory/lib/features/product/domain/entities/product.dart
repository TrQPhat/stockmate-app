import 'package:equatable/equatable.dart';

enum ProductStatus { conDung, hetHan, daDung, huy }

class Product extends Equatable {
  final String id;
  final String storageId;
  final String name;
  final String? category;
  final int quantity;
  final String? unit;
  final DateTime? importDate;
  final DateTime? expireDate;
  final String? note;
  final ProductStatus status;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.storageId,
    required this.name,
    this.category,
    required this.quantity,
    this.unit,
    this.importDate,
    this.expireDate,
    this.note,
    this.status = ProductStatus.conDung,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, storageId, name, category, quantity, unit,
    importDate, expireDate, note, status, imagePath,
    createdAt, updatedAt,
  ];
}
