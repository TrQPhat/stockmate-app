part of 'recipe_bloc.dart';

abstract class RecipeEvent extends Equatable {
  const RecipeEvent();
  @override
  List<Object> get props => [];
}

class LoadAllRecipes extends RecipeEvent {}

class LoadRecipeDetails extends RecipeEvent {
  final String id;
  const LoadRecipeDetails(this.id);
  @override
  List<Object> get props => [id];
}

class CreateRecipe extends RecipeEvent {
  final Map<String, dynamic> recipeData;
  const CreateRecipe(this.recipeData);
  @override
  List<Object> get props => [recipeData];
}

class DeleteRecipe extends RecipeEvent {
  final String recipeId;

  const DeleteRecipe(this.recipeId);

  @override
  List<Object> get props => [recipeId];
}
