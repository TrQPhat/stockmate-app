part of 'shopping_bloc.dart';

abstract class ShoppingEvent extends Equatable {
  const ShoppingEvent();
  @override
  List<Object?> get props => [];
}

// Events for Shopping Lists
class LoadShoppingLists extends ShoppingEvent {}

class CreateShoppingList extends ShoppingEvent {
  final String name;
  final DateTime purchaseDate;
  const CreateShoppingList(this.name, this.purchaseDate);
  @override
  List<Object> get props => [name, purchaseDate];
}

class DeleteShoppingList extends ShoppingEvent {
  final String listId;
  const DeleteShoppingList(this.listId);
  @override
  List<Object> get props => [listId];
}

// Events for Shopping List Items
class LoadShoppingListDetails extends ShoppingEvent {
  final String listId;
  const LoadShoppingListDetails(this.listId);
  @override
  List<Object> get props => [listId];
}

class AddItemToList extends ShoppingEvent {
  final String listId;
  final String itemName;
  final int quantity;
  final String? unit;
  final double price;

  const AddItemToList({
    required this.listId,
    required this.itemName,
    required this.quantity,
    this.unit,
    required this.price,
  });

  @override
  List<Object?> get props => [listId, itemName, quantity, unit, price];
}

class UpdateItemInList extends ShoppingEvent {
  final String listId;
  final ShoppingListItem item;

  const UpdateItemInList(this.listId, this.item);
  @override
  List<Object> get props => [listId, item];
}

class DeleteItemFromList extends ShoppingEvent {
  final String listId;
  final String itemId;

  const DeleteItemFromList(this.listId, this.itemId);
  @override
  List<Object> get props => [listId, itemId];
}

class UpdateShoppingList extends ShoppingEvent {
  final String listId;
  final String newName;
  final DateTime newPurchaseDate;

  const UpdateShoppingList(
      {required this.listId,
      required this.newName,
      required this.newPurchaseDate});

  @override
  List<Object> get props => [listId, newName, newPurchaseDate];
}
