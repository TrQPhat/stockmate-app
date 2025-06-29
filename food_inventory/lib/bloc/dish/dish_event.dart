import 'package:equatable/equatable.dart';

abstract class DishEvent extends Equatable {
  const DishEvent();

  @override
  List<Object> get props => [];
}

class LoadYourDishes extends DishEvent {}

class LoadSuggestDishes extends DishEvent {}
