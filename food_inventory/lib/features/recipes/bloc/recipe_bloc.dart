import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipeRepository _repository;

  RecipeBloc(this._repository) : super(RecipeInitial()) {
    on<LoadAllRecipes>(_onLoadAllRecipes);
    on<LoadRecipeDetails>(_onLoadRecipeDetails);
    on<CreateRecipe>(_onCreateRecipe);
    on<DeleteRecipe>(_onDeleteRecipe);
  }

  Future<void> _onLoadAllRecipes(
      LoadAllRecipes event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      final recipes = await _repository.getAllRecipes();
      emit(AllRecipesLoaded(recipes));
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> _onLoadRecipeDetails(
      LoadRecipeDetails event, Emitter<RecipeState> emit) async {
    emit(RecipeLoading());
    try {
      final recipe = await _repository.getRecipeById(event.id);
      emit(RecipeDetailsLoaded(recipe));
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> _onCreateRecipe(
      CreateRecipe event, Emitter<RecipeState> emit) async {
    try {
      await _repository.createRecipe(event.recipeData);
      emit(const RecipeOperationSuccess("Tạo công thức thành công!"));
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> _onDeleteRecipe(
      DeleteRecipe event, Emitter<RecipeState> emit) async {
    try {
      await _repository.deleteRecipe(event.recipeId);
      emit(const RecipeOperationSuccess("Xóa công thức thành công!"));
      // Tải lại danh sách sau khi xóa
      add(LoadAllRecipes());
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }
}
