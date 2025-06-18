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

  const IngredientsLoaded(this.ingredients);

  IngredientsLoaded copyWith({
    List<Ingredient>? ingredients,
  }) {
    return IngredientsLoaded(
      ingredients ?? this.ingredients,
    );
  }

  @override
  List<Object?> get props => [ingredients];
}

class IngredientsError extends IngredientsState {
  final String message;

  const IngredientsError(this.message);

  @override
  List<Object> get props => [message];
}
