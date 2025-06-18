import 'package:equatable/equatable.dart';

import 'shopping_list_item.dart';

class ShoppingList extends Equatable {
  final String id;
  final String userId;
  final String name;
  final DateTime? purchaseDate; // Thuộc tính bị thiếu là đây
  final double totalCost;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ShoppingListItem>? items;

  const ShoppingList({
    required this.id,
    required this.userId,
    required this.name,
    this.purchaseDate, // Thêm vào constructor
    required this.totalCost,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? 'Không có tên',
      // API trả về purchase_date dưới dạng string, cần parse
      purchaseDate: json['purchase_date'] != null
          ? DateTime.tryParse(json['purchase_date'])
          : null,
      // API trả về total_cost là string, cần parse
      totalCost:
          double.tryParse(json['total_cost']?.toString() ?? '0.0') ?? 0.0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      items: (json['items'] as List<dynamic>?)
          ?.map((itemJson) => ShoppingListItem.fromJson(itemJson))
          .toList(),
    );
  }

  ShoppingList copyWith({
    String? name,
    DateTime? purchaseDate,
    double? totalCost,
    List<ShoppingListItem>? items,
  }) {
    return ShoppingList(
      id: id,
      userId: userId,
      name: name ?? this.name,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      totalCost: totalCost ?? this.totalCost,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, name, purchaseDate, totalCost, createdAt, updatedAt, items];
}
