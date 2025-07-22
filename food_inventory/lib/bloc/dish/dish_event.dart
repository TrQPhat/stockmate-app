import 'package:equatable/equatable.dart';
import 'package:stock_mate/models/dish.dart';

abstract class DishEvent extends Equatable {
  const DishEvent();

  @override
  List<Object> get props => [];
}

class LoadYourDishes extends DishEvent {}

class LoadSuggestDishes extends DishEvent {}

class AddDish extends DishEvent {
  final Dish dish;

  const AddDish(this.dish);

  @override
  List<Object> get props => [dish];
}

class UpdateDish extends DishEvent {
  final int id;
  final Dish updatedDish;

  const UpdateDish({required this.id, required this.updatedDish});

  @override
  List<Object> get props => [id, updatedDish];
}

class DeleteDish extends DishEvent {
  final int id;

  const DeleteDish(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleFavoriteDish extends DishEvent {
  final int dishId;

  const ToggleFavoriteDish(this.dishId);

  @override
  List<Object> get props => [dishId];
}
