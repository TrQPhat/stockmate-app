import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/ingredient.dart';
import '../models/category.dart';
import '../repositories/ingredients_repository.dart';

part 'ingredients_event.dart';
part 'ingredients_state.dart';

class ProductsBloc extends Bloc<IngredientsEvent, IngredientsState> {
  final ProductsRepository _repository;

  ProductsBloc(this._repository) : super(IngredientsInitial()) {
    on<LoadIngredients>(_onLoadProducts);
    on<LoadCategories>(_onLoadCategories);
    on<CreateIngredient>(_onCreateProduct);
    on<UpdateIngredient>(_onUpdateProduct);
    on<DeleteIngredient>(_onDeleteProduct);
    on<SearchIngredients>(_onSearchProducts);
    on<FilterIngredientsByCategory>(_onFilterProductsByCategory);
  }

  Future<void> _onLoadProducts(
    LoadIngredients event,
    Emitter<IngredientsState> emit,
  ) async {
    emit(IngredientsLoading());

    try {
      final products = await _repository.getProducts(
        storageId: event.storageId,
        categoryId: event.categoryId,
      );
      emit(IngredientsLoaded(products));
    } catch (e) {
      emit(IngredientssError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<IngredientsState> emit,
  ) async {
    try {
      final categories = await _repository.getCategories();
      if (state is IngredientsLoaded) {
        final currentState = state as IngredientsLoaded;
        emit(currentState.copyWith(categories: categories));
      } else {
        emit(CategoriesLoaded(categories));
      }
    } catch (e) {
      emit(IngredientssError(e.toString()));
    }
  }

  Future<void> _onCreateProduct(
    CreateIngredient event,
    Emitter<IngredientsState> emit,
  ) async {
    try {
      final newProduct = await _repository.createProduct(event.ingredient);

      if (state is IngredientsLoaded) {
        final currentState = state as IngredientsLoaded;
        final updatedProducts = List<Ingredient>.from(currentState.ingredients)
          ..add(newProduct);
        emit(currentState.copyWith(ingredients: updatedProducts));
      }
    } catch (e) {
      emit(IngredientssError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateIngredient event,
    Emitter<IngredientsState> emit,
  ) async {
    try {
      final updatedProduct = await _repository.updateProduct(event.ingredient);

      if (state is IngredientsLoaded) {
        final currentState = state as IngredientsLoaded;
        final updatedProducts = currentState.ingredients.map((product) {
          return product.id == updatedProduct.id ? updatedProduct : product;
        }).toList();
        emit(currentState.copyWith(ingredients: updatedProducts));
      }
    } catch (e) {
      emit(IngredientssError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteIngredient event,
    Emitter<IngredientsState> emit,
  ) async {
    try {
      await _repository.deleteProduct(event.ingredientId);

      if (state is IngredientsLoaded) {
        final currentState = state as IngredientsLoaded;
        final updatedProducts = currentState.ingredients
            .where((product) => product.id != event.ingredientId)
            .toList();
        emit(currentState.copyWith(ingredients: updatedProducts));
      }
    } catch (e) {
      emit(IngredientssError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchIngredients event,
    Emitter<IngredientsState> emit,
  ) async {
    emit(IngredientsLoading());

    try {
      final products = await _repository.searchProducts(
        event.query,
        storageId: event.storageId,
      );
      emit(IngredientsLoaded(products));
    } catch (e) {
      emit(IngredientssError(e.toString()));
    }
  }

  Future<void> _onFilterProductsByCategory(
    FilterIngredientsByCategory event,
    Emitter<IngredientsState> emit,
  ) async {
    if (state is IngredientsLoaded) {
      final currentState = state as IngredientsLoaded;

      if (event.categoryId == null) {
        // Show all products
        add(LoadIngredients());
      } else {
        // Filter by category
        final filteredProducts = currentState.ingredients
            .where((product) => product.categoryId == event.categoryId)
            .toList();
        emit(currentState.copyWith(ingredients: filteredProducts));
      }
    }
  }
}
