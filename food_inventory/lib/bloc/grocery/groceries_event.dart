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

class LoadExpiredGroceries extends GroceriesEvent {
  final String? storageId;
  final String? categoryId;

  const LoadExpiredGroceries({this.storageId, this.categoryId});

  @override
  List<Object?> get props => [storageId, categoryId];
}

class LoadExpiringGroceries extends GroceriesEvent {
  final String? storageId;
  final String? categoryId;

  const LoadExpiringGroceries({this.storageId, this.categoryId});

  @override
  List<Object?> get props => [storageId, categoryId];
}

class CreateGrocery extends GroceriesEvent {
  final Grocery grocery;
  final File? imageFile;

  const CreateGrocery(this.grocery, this.imageFile);

  @override
  List<Object?> get props => [grocery, imageFile?.path];
}

class UpdateGrocery extends GroceriesEvent {
  final Grocery grocery;
  final File? imageFile;

  const UpdateGrocery(this.grocery, this.imageFile);

  @override
  List<Object?> get props => [grocery, imageFile?.path];
}

class DeleteGrocery extends GroceriesEvent {
  final int groceryId;

  const DeleteGrocery(this.groceryId);

  @override
  List<Object> get props => [groceryId];
}

class DeleteMultipleGroceries extends GroceriesEvent {
  final List<int> groceryIds;

  const DeleteMultipleGroceries(this.groceryIds);

  @override
  List<Object> get props => [groceryIds];
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
