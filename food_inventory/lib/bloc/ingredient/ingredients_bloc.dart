import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/ingredient.dart';
import '../../repositories/ingredients_repository.dart';

part 'ingredients_event.dart';
part 'ingredients_state.dart';

class IngredientsBloc extends Bloc<IngredientsEvent, IngredientsState> {
  final IngredientsRepository _repository;

  IngredientsBloc(this._repository) : super(IngredientsInitial()) {
    on<LoadIngredients>(_onLoadIngredients);
    on<CreateIngredient>(_onCreateIngredient);
    on<UpdateIngredient>(_onUpdateIngredient);
    on<DeleteIngredient>(_onDeleteIngredient);
    on<SearchIngredients>(_onSearchIngredients);
    on<FilterIngredientsByCategory>(_onFilterIngredientsByCategory);
  }

  Future<void> _onLoadIngredients(
    LoadIngredients event,
    Emitter<IngredientsState> emit,
  ) async {
    emit(IngredientsLoading());

    try {
      final ingredients =
          await _repository.getIngredients(storageId: event.storageId);
      emit(IngredientsLoaded(ingredients));
    } catch (e) {
      emit(IngredientsError(e.toString()));
    }
  }

  Future<void> _onCreateIngredient(
    CreateIngredient event,
    Emitter<IngredientsState> emit,
  ) async {
    try {
      final newIngredient =
          await _repository.createIngredient(event.ingredient);

      if (state is IngredientsLoaded) {
        final currentState = state as IngredientsLoaded;
        final updatedIngredients = [
          newIngredient,
          ...currentState.ingredients,
        ];
        emit(currentState.copyWith(ingredients: updatedIngredients));
      }
    } catch (e) {
      emit(const IngredientsError("Đã có lỗi xảy ra vui lòng thử lại."));
    }
  }

  Future<void> _onUpdateIngredient(
    UpdateIngredient event,
    Emitter<IngredientsState> emit,
  ) async {
    try {
      final updatedIngredient =
          await _repository.updateIngredient(event.ingredient);

      if (state is IngredientsLoaded) {
        final currentState = state as IngredientsLoaded;

        final updatedIngredients = currentState.ingredients.map((ingredient) {
          return ingredient.id == updatedIngredient.id
              ? updatedIngredient
              : ingredient;
        }).toList();

        emit(currentState.copyWith(ingredients: updatedIngredients));
      }
    } catch (e) {
      emit(IngredientsError("Cập nhật thất bại: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteIngredient(
    DeleteIngredient event,
    Emitter<IngredientsState> emit,
  ) async {
    try {
      await _repository.deleteIngredient(event.ingredientId);

      if (state is IngredientsLoaded) {
        final currentState = state as IngredientsLoaded;
        final updatedIngredients = currentState.ingredients
            .where((ingredient) => ingredient.id != event.ingredientId)
            .toList();
        emit(currentState.copyWith(ingredients: updatedIngredients));
      }
    } catch (e) {
      emit(IngredientsError(e.toString()));
    }
  }

  Future<void> _onSearchIngredients(
    SearchIngredients event,
    Emitter<IngredientsState> emit,
  ) async {
    emit(IngredientsLoading());

    try {
      final ingredients = await _repository.searchIngredients(
        event.query,
        storageId: event.storageId,
      );
      emit(IngredientsLoaded(ingredients));
    } catch (e) {
      emit(IngredientsError(e.toString()));
    }
  }

  Future<void> _onFilterIngredientsByCategory(
    FilterIngredientsByCategory event,
    Emitter<IngredientsState> emit,
  ) async {
    if (state is IngredientsLoaded) {
      final currentState = state as IngredientsLoaded;

      if (event.categoryId == null) {
        // Show all products
        add(const LoadIngredients());
      } else {
        // Filter by category
        final filteredIngredients = currentState.ingredients
            .where((ingredient) => ingredient.categoryId == event.categoryId)
            .toList();
        emit(currentState.copyWith(ingredients: filteredIngredients));
      }
    }
  }
}
