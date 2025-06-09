part of 'products_bloc.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final List<Category>? categories;

  const ProductsLoaded(this.products, {this.categories});

  ProductsLoaded copyWith({
    List<Product>? products,
    List<Category>? categories,
  }) {
    return ProductsLoaded(
      products ?? this.products,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [products, categories];
}

class CategoriesLoaded extends ProductsState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object> get props => [message];
}
