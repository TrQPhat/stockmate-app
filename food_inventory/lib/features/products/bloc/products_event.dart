part of 'products_bloc.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductsEvent {
  final String? storageId;
  final String? categoryId;

  const LoadProducts({this.storageId, this.categoryId});

  @override
  List<Object?> get props => [storageId, categoryId];
}

class LoadCategories extends ProductsEvent {}

class CreateProduct extends ProductsEvent {
  final Product product;

  const CreateProduct(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateProduct extends ProductsEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object> get props => [product];
}

class DeleteProduct extends ProductsEvent {
  final String productId;

  const DeleteProduct(this.productId);

  @override
  List<Object> get props => [productId];
}

class SearchProducts extends ProductsEvent {
  final String query;
  final String? storageId;

  const SearchProducts(this.query, {this.storageId});

  @override
  List<Object?> get props => [query, storageId];
}

class FilterProductsByCategory extends ProductsEvent {
  final String? categoryId;

  const FilterProductsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
