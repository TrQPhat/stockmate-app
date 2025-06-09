import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/product.dart';
import '../models/category.dart';
import '../repositories/products_repository.dart';

part 'products_event.dart';
part 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository _repository;

  ProductsBloc(this._repository) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadCategories>(_onLoadCategories);
    on<CreateProduct>(_onCreateProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    
    try {
      final products = await _repository.getProducts(
        storageId: event.storageId,
        categoryId: event.categoryId,
      );
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final categories = await _repository.getCategories();
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        emit(currentState.copyWith(categories: categories));
      } else {
        emit(CategoriesLoaded(categories));
      }
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onCreateProduct(
    CreateProduct event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final newProduct = await _repository.createProduct(event.product);
      
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        final updatedProducts = List<Product>.from(currentState.products)..add(newProduct);
        emit(currentState.copyWith(products: updatedProducts));
      }
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      final updatedProduct = await _repository.updateProduct(event.product);
      
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        final updatedProducts = currentState.products.map((product) {
          return product.id == updatedProduct.id ? updatedProduct : product;
        }).toList();
        emit(currentState.copyWith(products: updatedProducts));
      }
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductsState> emit,
  ) async {
    try {
      await _repository.deleteProduct(event.productId);
      
      if (state is ProductsLoaded) {
        final currentState = state as ProductsLoaded;
        final updatedProducts = currentState.products
            .where((product) => product.id != event.productId)
            .toList();
        emit(currentState.copyWith(products: updatedProducts));
      }
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    
    try {
      final products = await _repository.searchProducts(
        event.query,
        storageId: event.storageId,
      );
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onFilterProductsByCategory(
    FilterProductsByCategory event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      
      if (event.categoryId == null) {
        // Show all products
        add(LoadProducts());
      } else {
        // Filter by category
        final filteredProducts = currentState.products
            .where((product) => product.categoryId == event.categoryId)
            .toList();
        emit(currentState.copyWith(products: filteredProducts));
      }
    }
  }
}
