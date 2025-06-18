import 'package:equatable/equatable.dart';

class ShoppingListItem extends Equatable {
  final String id;
  final String shoppingListId;
  final String? productId;
  final String itemName;
  final int quantity;
  final String? unit;
  final bool isPurchased;
  final DateTime createdAt;

  const ShoppingListItem({
    required this.id,
    required this.shoppingListId,
    this.productId,
    required this.itemName,
    required this.quantity,
    this.unit,
    required this.isPurchased,
    required this.createdAt,
  });

  // Factory constructor từ JSON
  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'] ?? '',
      shoppingListId: json['shopping_list_id'] ?? '',
      productId: json['product_id'],
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unit: json['unit'],
      isPurchased: json['is_purchased'] == 1 || json['is_purchased'] == true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Chuyển object về JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopping_list_id': shoppingListId,
      'product_id': productId,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'is_purchased': isPurchased ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ShoppingListItem copyWith({
    String? id,
    String? shoppingListId,
    String? productId,
    String? itemName,
    int? quantity,
    String? unit,
    bool? isPurchased,
    DateTime? createdAt,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      productId: productId ?? this.productId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    shoppingListId,
    productId,
    itemName,
    quantity,
    unit,
    isPurchased,
    createdAt,
  ];
}
