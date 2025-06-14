part of 'ingredients_bloc.dart';

abstract class IngredientsState extends Equatable {
  const IngredientsState();

  @override
  List<Object?> get props => [];
}

class IngredientsInitial extends IngredientsState {}

class IngredientsLoading extends IngredientsState {}

class IngredientsLoaded extends IngredientsState {
  final List<Ingredient> ingredients;
  final List<Category>? categories;

  const IngredientsLoaded(this.ingredients, {this.categories});

  IngredientsLoaded copyWith({
    List<Ingredient>? ingredients,
    List<Category>? categories,
  }) {
    return IngredientsLoaded(
      ingredients ?? this.ingredients,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [ingredients, categories];
}

class CategoriesLoaded extends IngredientsState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class IngredientssError extends IngredientsState {
  final String message;

  const IngredientssError(this.message);

  @override
  List<Object> get props => [message];
}
