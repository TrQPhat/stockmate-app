import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/repositories/shopping_item_repository.dart';
import 'package:stock_mate/models/shopping_list.dart';
import 'package:stock_mate/models/shopping_item.dart';

part 'shopping_item_event.dart';
part 'shopping_item_state.dart';

class ShoppingItemBloc extends Bloc<ShoppingItemEvent, ShoppingItemState> {
  final ShoppingItemRepository _repository;

  ShoppingItemBloc(this._repository) : super(ShoppingInitial()) {
    on<LoadShoppingList>(_onLoadShoppingList); //Load danh sách
    on<AddItemEvent>(_onAddItemToList); // Thêm item
    on<UpdateItemEvent>(_onUpdateItemInList); //cập nhật item
    on<PurchaseStatusChangedEvent>(
        _onChangePurchaseStatus); // thay đổi trạng thái mua
    on<DeleteItemEvent>(_onDeleteItemFromList); //Xoá item
    on<UpdateListEvent>(_onUpdateList); //Cập nhật danh sách
    on<DeleteListEvent>(_onDeleteShoppingList);
  }

  Future<void> _onLoadShoppingList(
      LoadShoppingList event, Emitter<ShoppingItemState> emit) async {
    emit(ShoppingLoading());

    try {
      final shoppingList = await _repository.getShoppingList(event.listId);
      emit(ShoppingListLoaded(shoppingList));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onAddItemToList(
    AddItemEvent event,
    Emitter<ShoppingItemState> emit,
  ) async {
    try {
      final newItem = await _repository.addItemToList(
        listId: event.listId,
        itemName: event.itemName,
        quantity: event.quantity,
        unit: event.unit,
        expire: event.expiredDate,
        categoryId: event.categoryId,
      );

      if (state is ShoppingListLoaded) {
        final currentState = state as ShoppingListLoaded;

        // Cập nhật danh sách item
        final updatedItems =
            List<ShoppingItem>.from(currentState.listDetails.items!)
              ..add(newItem);

        // Tạo bản mới của ShoppingList với danh sách item mới
        final updatedList =
            currentState.listDetails.copyWith(items: updatedItems);

        emit(ShoppingListLoaded(updatedList));
      }
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onUpdateItemInList(
      UpdateItemEvent event, Emitter<ShoppingItemState> emit) async {
    try {
      await _repository.updateItemInList(event.listId, event.item);
      //add(LoadShoppingListDetails(event.listId));
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onChangePurchaseStatus(
    PurchaseStatusChangedEvent event,
    Emitter<ShoppingItemState> emit,
  ) async {
    final currentState = state;

    if (currentState is ShoppingListLoaded) {
      try {
        // Gửi yêu cầu cập nhật trạng thái mua
        await _repository.changePurchaseStatus(event.itemId);

        // Tạo bản sao danh sách items để cập nhật
        final updatedItems = currentState.listDetails.items?.map((item) {
          if (item.id == event.itemId) {
            return item.copyWith(
                isPurchased: !item.isPurchased); // Đảo trạng thái
          }
          return item;
        }).toList();

        // Tạo ShoppingList mới với danh sách items đã cập nhật
        final updatedList =
            currentState.listDetails.copyWith(items: updatedItems);

        // Emit lại state mới
        emit(ShoppingListLoaded(updatedList));
      } catch (e) {
        emit(ShoppingError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteItemFromList(
      DeleteItemEvent event, Emitter<ShoppingItemState> emit) async {
    try {
      await _repository.deleteItemFromList(event.itemId);

      if (state is ShoppingListLoaded) {
        final currentState = state as ShoppingListLoaded;
        final updatedItems = currentState.listDetails.items
            ?.where((item) => item.id != event.itemId)
            .toList();

        final updatedList =
            currentState.listDetails.copyWith(items: updatedItems);
        emit(ShoppingListLoaded(updatedList));
      }
    } catch (e) {
      emit(ShoppingError(e.toString()));
    }
  }

  Future<void> _onUpdateList(
    UpdateListEvent event,
    Emitter<ShoppingItemState> emit,
  ) async {
    ShoppingList? currentList;
    if (state is ShoppingListLoaded) {
      currentList = (state as ShoppingListLoaded).listDetails;
    }

    if (currentList == null) {
      emit(const ShoppingError('Không có danh sách hiện tại để cập nhật.'));
      return;
    }

    emit(ShoppingLoading());

    try {
      await _repository.updateShoppingList(event.listId, {
        'name': event.newName,
        'purchase_date': event.newPurchaseDate.toIso8601String(),
      });

      // Tạo bản sao danh sách đã được cập nhật
      final updatedList = ShoppingList(
        id: currentList.id,
        storageId: currentList.storageId,
        name: event.newName,
        purchaseDate: event.newPurchaseDate,
        purpose: currentList.purpose,
        items: currentList.items,
      );

      emit(ShoppingListLoaded(updatedList));
    } catch (e) {
      emit(ShoppingError('Cập nhật danh sách thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteShoppingList(
    DeleteListEvent event,
    Emitter<ShoppingItemState> emit,
  ) async {
    emit(ShoppingLoading());

    try {
      await _repository.deleteShoppingList(event.listId);

      emit(ShoppingOperationSuccess());
    } catch (e) {
      emit(ShoppingError('Xóa danh sách thất bại: ${e.toString()}'));
    }
  }
}
