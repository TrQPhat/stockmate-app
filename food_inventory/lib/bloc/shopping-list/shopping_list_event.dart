part of 'shopping_list_bloc.dart';

abstract class ShoppingListEvent extends Equatable {
  const ShoppingListEvent();
  @override
  List<Object?> get props => [];
}

// Events for Shopping Lists
class LoadShoppingLists extends ShoppingListEvent {}

class CreateShoppingList extends ShoppingListEvent {
  final String name;
  final String purpose;
  final DateTime purchaseDate;
  const CreateShoppingList(this.name, this.purpose, this.purchaseDate);
  @override
  List<Object> get props => [name, purpose, purchaseDate];
}

class DeleteShoppingList extends ShoppingListEvent {
  final int listId;
  const DeleteShoppingList(this.listId);
  @override
  List<Object> get props => [listId];
}

class UpdateShoppingList extends ShoppingListEvent {
  final int listId;
  final String newName;
  final DateTime newPurchaseDate;

  const UpdateShoppingList(
      {required this.listId,
      required this.newName,
      required this.newPurchaseDate});

  @override
  List<Object> get props => [listId, newName, newPurchaseDate];
}

class CompleteShoppingListEvent extends ShoppingListEvent {
  final int listId;

  const CompleteShoppingListEvent(this.listId);

  @override
  List<Object?> get props => [listId];
}

//tạo thêm một sự kiện cập nhật item trong danh sách mua sắm
class UpdateShoppingItemEvent extends ShoppingListEvent {
  final int listId;
  final ShoppingItem item;

  const UpdateShoppingItemEvent(this.listId, this.item);

  @override
  List<Object> get props => [listId, item];
}
