import 'package:equatable/equatable.dart';

class ShoppingListItem extends Equatable {
  final String id;
  final String shoppingListId;
  final String? productId;
  final String itemName;
  final int quantity;
  final String? unit;
  final double price; // Thuộc tính bị thiếu là đây
  final bool isPurchased;
  final DateTime createdAt;

  const ShoppingListItem({
    required this.id,
    required this.shoppingListId,
    this.productId,
    required this.itemName,
    required this.quantity,
    this.unit,
    required this.price, // Thêm vào constructor
    required this.isPurchased,
    required this.createdAt,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'] ?? '',
      shoppingListId: json['shopping_list_id'] ?? '',
      productId: json['product_id'],
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unit: json['unit'],
      price: double.tryParse(json['price']?.toString() ?? '0.0') ??
          0.0, // Thêm logic parse giá tiền
      isPurchased: json['is_purchased'] ?? false,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  ShoppingListItem copyWith({
    int? quantity,
    String? unit,
    double? price,
    bool? isPurchased,
    String? itemName,
  }) {
    return ShoppingListItem(
      id: id,
      shoppingListId: shoppingListId,
      productId: productId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      isPurchased: isPurchased ?? this.isPurchased,
      createdAt: createdAt,
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
        price,
        isPurchased,
        createdAt,
      ];
}
