part of 'shopping_list_bloc.dart';

abstract class ShoppingListState extends Equatable {
  const ShoppingListState();
  @override
  List<Object?> get props => [];
}

class ShoppingInitial extends ShoppingListState {}

class ShoppingLoading extends ShoppingListState {}

class ShoppingListsLoaded extends ShoppingListState {
  final List<ShoppingList> lists;
  const ShoppingListsLoaded(this.lists);
  ShoppingListsLoaded copyWith({
    List<ShoppingList>? lists,
  }) {
    return ShoppingListsLoaded(
      lists ?? this.lists,
    );
  }

  @override
  List<Object> get props => [lists];
}

class ShoppingError extends ShoppingListState {
  final String message;
  const ShoppingError(this.message);
  @override
  List<Object> get props => [message];
}

class ShoppingOperationSuccess extends ShoppingListState {}
