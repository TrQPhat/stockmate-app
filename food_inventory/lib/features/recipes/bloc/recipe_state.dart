part of 'recipe_bloc.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();
  @override
  List<Object> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class AllRecipesLoaded extends RecipeState {
  final List<Recipe> recipes;
  const AllRecipesLoaded(this.recipes);
  @override
  List<Object> get props => [recipes];
}

class RecipeDetailsLoaded extends RecipeState {
  final Recipe recipe;
  const RecipeDetailsLoaded(this.recipe);
  @override
  List<Object> get props => [recipe];
}

class RecipeOperationSuccess extends RecipeState {
  final String message;
  const RecipeOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class RecipeError extends RecipeState {
  final String message;
  const RecipeError(this.message);
  @override
  List<Object> get props => [message];
}
