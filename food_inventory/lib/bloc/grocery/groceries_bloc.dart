import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/grocery.dart';
import '../../repositories/groceries_repository.dart';

part 'groceries_event.dart';
part 'groceries_state.dart';

class GroceriesBloc extends Bloc<GroceriesEvent, GroceriesState> {
  final GroceriesRepository _repository;

  GroceriesBloc(this._repository) : super(GroceriesInitial()) {
    on<LoadGroceries>(_onLoadGroceries);
    on<CreateGrocery>(_onCreateGrocery);
    on<UpdateGrocery>(_onUpdateGrocery);
    on<DeleteGrocery>(_onDeleteGrocery);
    on<SearchGroceries>(_onSearchGroceries);
    on<FilterGroceriesByCategory>(_onFilterGroceriesByCategory);
  }

  Future<void> _onLoadGroceries(
    LoadGroceries event,
    Emitter<GroceriesState> emit,
  ) async {
    emit(GroceriesLoading());

    try {
      final groceries =
          await _repository.getGroceries(storageId: event.storageId);
      emit(GroceriesLoaded(groceries));
    } catch (e) {
      emit(GroceriesError(e.toString()));
    }
  }

  Future<void> _onCreateGrocery(
    CreateGrocery event,
    Emitter<GroceriesState> emit,
  ) async {
    try {
      final newGrocery = await _repository.createGrocery(event.grocery);

      if (state is GroceriesLoaded) {
        final currentState = state as GroceriesLoaded;
        final updatedGroceries = [
          newGrocery,
          ...currentState.groceries,
        ];
        emit(currentState.copyWith(groceries: updatedGroceries));
      }
    } catch (e) {
      emit(const GroceriesError("Đã có lỗi xảy ra vui lòng thử lại."));
    }
  }

  Future<void> _onUpdateGrocery(
    UpdateGrocery event,
    Emitter<GroceriesState> emit,
  ) async {
    try {
      final updatedGrocery = await _repository.updateGrocery(event.grocery);

      if (state is GroceriesLoaded) {
        final currentState = state as GroceriesLoaded;

        final updatedGroceries = currentState.groceries.map((grocery) {
          return grocery.id == updatedGrocery.id ? updatedGrocery : grocery;
        }).toList();

        emit(currentState.copyWith(groceries: updatedGroceries));
      }
    } catch (e) {
      emit(GroceriesError("Cập nhật thất bại: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteGrocery(
    DeleteGrocery event,
    Emitter<GroceriesState> emit,
  ) async {
    try {
      await _repository.deleteGrocery(event.groceryId);

      if (state is GroceriesLoaded) {
        final currentState = state as GroceriesLoaded;
        final updatedGroceries = currentState.groceries
            .where((grocery) => grocery.id != event.groceryId)
            .toList();
        emit(currentState.copyWith(groceries: updatedGroceries));
      }
    } catch (e) {
      emit(GroceriesError(e.toString()));
    }
  }

  Future<void> _onSearchGroceries(
    SearchGroceries event,
    Emitter<GroceriesState> emit,
  ) async {
    emit(GroceriesLoading());

    try {
      final groceries = await _repository.searchGroceries(
        event.query,
        storageId: event.storageId,
      );
      emit(GroceriesLoaded(groceries));
    } catch (e) {
      emit(GroceriesError(e.toString()));
    }
  }

  Future<void> _onFilterGroceriesByCategory(
    FilterGroceriesByCategory event,
    Emitter<GroceriesState> emit,
  ) async {
    if (state is GroceriesLoaded) {
      final currentState = state as GroceriesLoaded;

      if (event.categoryId == null) {
        // Show all products
        add(const LoadGroceries());
      } else {
        // Filter by category
        final filteredGroceries = currentState.groceries
            .where((grocery) => grocery.categoryId == event.categoryId)
            .toList();
        emit(currentState.copyWith(groceries: filteredGroceries));
      }
    }
  }
}
