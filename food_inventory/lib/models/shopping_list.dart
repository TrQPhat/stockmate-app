import 'package:equatable/equatable.dart';
import 'package:stock_mate/models/shopping_item.dart';

class ShoppingList extends Equatable {
  final int id;
  final int storageId;
  final String name;
  final String purpose;
  final DateTime? purchaseDate;
  final List<ShoppingItem>? items;

  const ShoppingList({
    required this.id,
    required this.storageId,
    required this.name,
    required this.purpose,
    this.purchaseDate,
    this.items,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'],
      storageId: json['storage_id'],
      name: json['name'],
      purpose: json['purpose'],
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'])
          : null,
      items: (json['items'] as List<dynamic>?)
          ?.map((itemJson) => ShoppingItem.fromJson(itemJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storage_id': storageId,
      'name': name,
      'purpose': purpose,
      'purchase_date': purchaseDate?.toIso8601String(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }

  ShoppingList copyWith({
    int? id,
    int? storageId,
    String? name,
    String? purpose,
    DateTime? purchaseDate,
    List<ShoppingItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      storageId: storageId ?? this.storageId,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props =>
      [id, storageId, name, purpose, purchaseDate, items];
}
