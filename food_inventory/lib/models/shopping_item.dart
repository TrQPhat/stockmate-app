import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  final int id;
  final int listId;
  final String itemName;
  final int quantity;
  final String? unit;
  final DateTime? expire;
  final int categoryId;
  final bool isPurchased;

  const ShoppingItem({
    required this.id,
    required this.listId,
    required this.itemName,
    required this.quantity,
    this.unit,
    this.expire,
    required this.categoryId,
    required this.isPurchased,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] ?? -1,
      listId: json['list_id'] ?? -1,
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unit: json['unit'],
      expire: DateTime.parse(json['expire']),
      isPurchased: json['is_purchased'] ?? false,
      categoryId: json['category_id'] ?? -1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'list_id': listId,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'expire': expire?.toIso8601String(),
      'is_purchased': isPurchased,
      'category_id': categoryId,
    };
  }

  ShoppingItem copyWith({
    int? quantity,
    String? unit,
    double? price,
    bool? isPurchased,
    String? itemName,
    DateTime? expire,
  }) {
    return ShoppingItem(
      id: id,
      listId: listId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
      expire: expire ?? this.expire,
      categoryId: categoryId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        listId,
        itemName,
        quantity,
        unit,
        expire,
        isPurchased,
      ];
}
