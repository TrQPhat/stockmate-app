part of 'ingredients_bloc.dart';

abstract class IngredientsEvent extends Equatable {
  const IngredientsEvent();

  @override
  List<Object?> get props => [];
}

class LoadIngredients extends IngredientsEvent {
  final String? storageId;
  final String? categoryId;

  const LoadIngredients({this.storageId, this.categoryId});

  @override
  List<Object?> get props => [storageId, categoryId];
}

class LoadCategories extends IngredientsEvent {}

class CreateIngredient extends IngredientsEvent {
  final Ingredient ingredient;

  const CreateIngredient(this.ingredient);

  @override
  List<Object> get props => [ingredient];
}

class UpdateIngredient extends IngredientsEvent {
  final Ingredient ingredient;

  const UpdateIngredient(this.ingredient);

  @override
  List<Object> get props => [ingredient];
}

class DeleteIngredient extends IngredientsEvent {
  final String ingredientId;

  const DeleteIngredient(this.ingredientId);

  @override
  List<Object> get props => [ingredientId];
}

class SearchIngredients extends IngredientsEvent {
  final String query;
  final String? storageId;

  const SearchIngredients(this.query, {this.storageId});

  @override
  List<Object?> get props => [query, storageId];
}

class FilterIngredientsByCategory extends IngredientsEvent {
  final String? categoryId;

  const FilterIngredientsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
