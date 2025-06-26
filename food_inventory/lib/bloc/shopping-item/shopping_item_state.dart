part of 'shopping_item_bloc.dart';

abstract class ShoppingItemState extends Equatable {
  const ShoppingItemState();
  @override
  List<Object?> get props => [];
}

class ShoppingInitial extends ShoppingItemState {}

class ShoppingLoading extends ShoppingItemState {}

class ShoppingListLoaded extends ShoppingItemState {
  final ShoppingList listDetails;
  const ShoppingListLoaded(this.listDetails);

  @override
  List<Object?> get props => [listDetails];
}

class ShoppingError extends ShoppingItemState {
  final String message;
  const ShoppingError(this.message);
  @override
  List<Object> get props => [message];
}

class ShoppingOperationSuccess extends ShoppingItemState {}
