import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/features/shopping/models/shopping_list.dart';
import 'package:stock_mate/features/shopping/models/shopping_list_item.dart';
import 'package:stock_mate/features/shopping/repository/shopping_repository.dart';

part 'shopping_event.dart';
part 'shopping_state.dart';

class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  final ShoppingRepository _repository;

  ShoppingBloc(this._repository) : super(ShoppingInitial()) {
    on<LoadShoppingLists>(_onLoadShoppingLists);
    on<CreateShoppingList>(_onCreateShoppingList);
    on<DeleteShoppingList>(_onDeleteShoppingList);
    on<LoadShoppingListDetails>(_onLoadShoppingListDetails);
    on<AddItemToList>(_onAddItemToList);
    on<UpdateItemInList>(_onUpdateItemInList);
    on<DeleteItemFromList>(_onDeleteItemFromList);
    on<UpdateShoppingList>(_onUpdateShoppingList);
  }

  Future<void> _onLoadShoppingLists(
      LoadShoppingLists event, Emitter<ShoppingState> emit) async {
    if (state is ShoppingListsLoaded) {
      final currentState = state as ShoppingListsLoaded;
      if (!currentState.isLoading) {
        emit(currentState.copyWith(isLoading: true));
      }
    } else {
      emit(ShoppingLoading());
    }
    try {
      final lists = await _repository.getShoppingLists();
      emit(ShoppingListsLoaded(lists, isLoading: false));
    } catch (e) {
      // Quan trọng: Luôn phát ra state Error để không bị kẹt ở loading.
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onCreateShoppingList(
      CreateShoppingList event, Emitter<ShoppingState> emit) async {
    if (state is ShoppingListsLoaded) {
      final currentState = state as ShoppingListsLoaded;
      emit(currentState.copyWith(isLoading: true));
    }
    try {
      await _repository.createShoppingList(event.name, event.purchaseDate);
      add(LoadShoppingLists());
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onDeleteShoppingList(
      DeleteShoppingList event, Emitter<ShoppingState> emit) async {
    try {
      await _repository.deleteShoppingList(event.listId);
      emit(ShoppingOperationSuccess());
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onLoadShoppingListDetails(
      LoadShoppingListDetails event, Emitter<ShoppingState> emit) async {
    final currentState = state;
    if (currentState is ShoppingListDetailsLoaded &&
        currentState.listDetails.id == event.listId) {
      if (!currentState.isLoading) {
        emit(currentState.copyWith(isLoading: true));
      }
    } else {
      emit(ShoppingLoading());
    }

    try {
      final details = await _repository.getShoppingListDetails(event.listId);
      emit(ShoppingListDetailsLoaded(details));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onAddItemToList(
      AddItemToList event, Emitter<ShoppingState> emit) async {
    try {
      await _repository.addItemToList(
        listId: event.listId,
        itemName: event.itemName,
        quantity: event.quantity,
        unit: event.unit,
        price: event.price,
      );
      add(LoadShoppingListDetails(event.listId));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onUpdateItemInList(
      UpdateItemInList event, Emitter<ShoppingState> emit) async {
    try {
      await _repository.updateItemInList(event.listId, event.item);
      add(LoadShoppingListDetails(event.listId));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onDeleteItemFromList(
      DeleteItemFromList event, Emitter<ShoppingState> emit) async {
    try {
      await _repository.deleteItemFromList(event.listId, event.itemId);
      add(LoadShoppingListDetails(event.listId));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onUpdateShoppingList(
      UpdateShoppingList event, Emitter<ShoppingState> emit) async {
    try {
      await _repository.updateShoppingList(
          event.listId, event.newName, event.newPurchaseDate);
      add(LoadShoppingListDetails(event.listId));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }
}
