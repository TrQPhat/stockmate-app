part of 'shopping_bloc.dart';

abstract class ShoppingState extends Equatable {
  const ShoppingState();
  @override
  List<Object?> get props => [];
}

class ShoppingInitial extends ShoppingState {}

class ShoppingLoading extends ShoppingState {}

class ShoppingListsLoaded extends ShoppingState {
  final List<ShoppingList> lists;
  final bool isLoading;
  const ShoppingListsLoaded(this.lists, {this.isLoading = false});
  ShoppingListsLoaded copyWith({
    List<ShoppingList>? lists,
    bool? isLoading,
  }) {
    return ShoppingListsLoaded(
      lists ?? this.lists,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [lists, isLoading];
}

class ShoppingListDetailsLoaded extends ShoppingState {
  final ShoppingList listDetails;
  final bool isLoading;
  const ShoppingListDetailsLoaded(this.listDetails, {this.isLoading = false});
  ShoppingListDetailsLoaded copyWith({
    ShoppingList? listDetails,
    bool? isLoading,
  }) {
    return ShoppingListDetailsLoaded(
      listDetails ?? this.listDetails,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [listDetails, isLoading];
}

class ShoppingError extends ShoppingState {
  final String message;
  const ShoppingError(this.message);
  @override
  List<Object> get props => [message];
}

class ShoppingOperationSuccess extends ShoppingState {}
