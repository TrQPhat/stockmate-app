part of 'shopping_item_bloc.dart';

abstract class ShoppingItemState extends Equatable {
  const ShoppingItemState();
  @override
  List<Object?> get props => [];
}

class ShoppingItemInitial extends ShoppingItemState {}

class ShoppingItemLoading extends ShoppingItemState {}

class ShoppingListLoaded extends ShoppingItemState {
  final ShoppingList listDetails;
  const ShoppingListLoaded(this.listDetails);

  @override
  List<Object?> get props => [listDetails];
}

class ShoppingItemError extends ShoppingItemState {
  final String message;
  const ShoppingItemError(this.message);
  @override
  List<Object> get props => [message];
}

class ShoppingItemOperationSuccess extends ShoppingItemState {}
