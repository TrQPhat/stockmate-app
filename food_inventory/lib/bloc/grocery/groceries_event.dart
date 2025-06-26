part of 'groceries_bloc.dart';

abstract class GroceriesEvent extends Equatable {
  const GroceriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroceries extends GroceriesEvent {
  final String? storageId;
  final String? categoryId;

  const LoadGroceries({this.storageId, this.categoryId});

  @override
  List<Object?> get props => [storageId, categoryId];
}

class CreateGrocery extends GroceriesEvent {
  final Grocery grocery;

  const CreateGrocery(this.grocery);

  @override
  List<Object> get props => [grocery];
}

class UpdateGrocery extends GroceriesEvent {
  final Grocery grocery;

  const UpdateGrocery(this.grocery);

  @override
  List<Object> get props => [grocery];
}

class DeleteGrocery extends GroceriesEvent {
  final int groceryId;

  const DeleteGrocery(this.groceryId);

  @override
  List<Object> get props => [groceryId];
}

class SearchGroceries extends GroceriesEvent {
  final String query;
  final String? storageId;

  const SearchGroceries(this.query, {this.storageId});

  @override
  List<Object?> get props => [query, storageId];
}

class FilterGroceriesByCategory extends GroceriesEvent {
  final String? categoryId;

  const FilterGroceriesByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
