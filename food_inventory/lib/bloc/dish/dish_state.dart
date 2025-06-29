import 'package:equatable/equatable.dart';
import 'package:stock_mate/models/dish.dart';

abstract class DishState extends Equatable {
  const DishState();

  @override
  List<Object?> get props => [];
}

class DishInitial extends DishState {}

class DishLoading extends DishState {}

class DishLoaded extends DishState {
  final List<Dish> dishes;

  const DishLoaded(this.dishes);

  @override
  List<Object?> get props => [dishes];
}

class DishError extends DishState {
  final String message;

  const DishError(this.message);

  @override
  List<Object?> get props => [message];
}
