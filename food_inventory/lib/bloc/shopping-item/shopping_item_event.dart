part of 'shopping_item_bloc.dart';

abstract class ShoppingItemEvent extends Equatable {
  const ShoppingItemEvent();
  @override
  List<Object?> get props => [];
}

class LoadShoppingList extends ShoppingItemEvent {
  final int listId;
  const LoadShoppingList(this.listId);
  @override
  List<Object> get props => [listId];
}

class AddItemEvent extends ShoppingItemEvent {
  final int listId;
  final String itemName;
  final int quantity;
  final String unit;
  final bool isPurchased;
  final DateTime expiredDate;
  final int categoryId;

  const AddItemEvent({
    required this.listId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    this.isPurchased = false,
    required this.expiredDate,
    required this.categoryId,
  });

  @override
  List<Object?> get props =>
      [listId, itemName, quantity, unit, isPurchased, expiredDate, categoryId];
}

class UpdateItemEvent extends ShoppingItemEvent {
  final int listId;
  final ShoppingItem item;

  const UpdateItemEvent(this.listId, this.item);
  @override
  List<Object> get props => [listId, item];
}

class PurchaseStatusChangedEvent extends ShoppingItemEvent {
  final int itemId;

  const PurchaseStatusChangedEvent(this.itemId);
  @override
  List<Object> get props => [itemId];
}

class DeleteItemEvent extends ShoppingItemEvent {
  final int itemId;

  const DeleteItemEvent(this.itemId);
  @override
  List<Object> get props => [itemId];
}

class DeleteListEvent extends ShoppingItemEvent {
  final int listId;

  const DeleteListEvent(this.listId);
  @override
  List<Object> get props => [listId];
}

class UpdateListEvent extends ShoppingItemEvent {
  final int listId;
  final String newName;
  final DateTime newPurchaseDate;

  const UpdateListEvent(
      {required this.listId,
      required this.newName,
      required this.newPurchaseDate});

  @override
  List<Object> get props => [listId, newName, newPurchaseDate];
}
