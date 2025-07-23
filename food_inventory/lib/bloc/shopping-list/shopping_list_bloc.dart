import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/models/shopping_item.dart';
import 'package:stock_mate/repositories/shopping_list_repository.dart';
import 'package:stock_mate/models/shopping_list.dart';

part 'shopping_list_event.dart';
part 'shopping_list_state.dart';

class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  final ShoppingListRepository _repository;

  ShoppingListBloc(this._repository) : super(ShoppingInitial()) {
    on<LoadShoppingLists>(_onLoadShoppingLists);
    on<CreateShoppingList>(_onCreateShoppingList);
    on<DeleteShoppingList>(_onDeleteShoppingList);
    on<UpdateShoppingList>(_onUpdateShoppingList);
    on<CompleteShoppingListEvent>(_onCompleteShoppingList);
    on<UpdateShoppingItemEvent>(_onUpdateShoppingItem);
  }

  Future<void> _onLoadShoppingLists(
      LoadShoppingLists event, Emitter<ShoppingListState> emit) async {
    try {
      final lists = await _repository.getShoppingLists();
      print("Danh sách mua sắm đã tải: ${jsonEncode(lists)}");
      emit(ShoppingListsLoaded(lists));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onCreateShoppingList(
    CreateShoppingList event,
    Emitter<ShoppingListState> emit,
  ) async {
    if (state is ShoppingListsLoaded) {
      final currentState = state as ShoppingListsLoaded;

      try {
        final newList = await _repository.createShoppingList(
          event.name,
          event.purpose,
          event.purchaseDate,
        );

        final updatedLists = List<ShoppingList>.from(currentState.lists)
          ..add(newList)
          ..sort((a, b) {
            final aDate = a.purchaseDate;
            final bDate = b.purchaseDate;
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return aDate.compareTo(bDate);
          });

        emit(
          ShoppingListsLoaded(
            updatedLists,
          ),
        );
      } catch (e) {
        emit(ShoppingError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteShoppingList(
    DeleteShoppingList event,
    Emitter<ShoppingListState> emit,
  ) async {
    try {
      await _repository.deleteShoppingList(event.listId);

      if (state is ShoppingListsLoaded) {
        final currentState = state as ShoppingListsLoaded;

        final updatedLists = currentState.lists
            .where((list) => list.id != event.listId)
            .toList();

        emit(ShoppingListsLoaded(updatedLists));
      }
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onUpdateShoppingList(
      UpdateShoppingList event, Emitter<ShoppingListState> emit) async {
    // try {
    //   await _repository.updateShoppingList(
    //       event.listId, event.newName, event.newPurchaseDate);
    //   add(LoadShoppingListDetails(event.listId));
    // } catch (e) {
    //   emit(ShoppingError(e.toString()));
    // }
  }

  Future<void> _onCompleteShoppingList(
    CompleteShoppingListEvent event,
    Emitter<ShoppingListState> emit,
  ) async {
    try {
      await _repository.completeShoppingList(event.listId);
      if (state is ShoppingListsLoaded) {
        final currentState = state as ShoppingListsLoaded;

        final updatedLists = currentState.lists
            .where((list) => list.id != event.listId)
            .toList();

        emit(ShoppingListsLoaded(updatedLists));
      }
    } catch (e) {
      emit(const ShoppingError('Đã có lỗi xảy ra, vui lòng thử lại.'));
    }
  }

  Future<void> _onUpdateShoppingItem(
    UpdateShoppingItemEvent event,
    Emitter<ShoppingListState> emit,
  ) async {
    if (state is ShoppingListsLoaded) {
      final currentState = state as ShoppingListsLoaded;

      final updatedLists = currentState.lists.map((list) {
        if (list.id == event.listId) {
          final updatedItems = list.items?.map((item) {
            if (item.id == event.item.id) {
              // Chỉ cập nhật isPurchased
              return item.copyWith(isPurchased: event.item.isPurchased);
            }
            return item;
          }).toList();

          return list.copyWith(items: updatedItems);
        }
        return list;
      }).toList();

      emit(ShoppingListsLoaded(updatedLists));
    }
  }
}
