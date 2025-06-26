part of 'groceries_bloc.dart';

abstract class GroceriesState extends Equatable {
  const GroceriesState();

  @override
  List<Object?> get props => [];
}

class GroceriesInitial extends GroceriesState {}

class GroceriesLoading extends GroceriesState {}

class GroceriesLoaded extends GroceriesState {
  final List<Grocery> groceries;

  const GroceriesLoaded(this.groceries);

  GroceriesLoaded copyWith({
    List<Grocery>? groceries,
  }) {
    return GroceriesLoaded(
      groceries ?? this.groceries,
    );
  }

  @override
  List<Object?> get props => [groceries];
}

class GroceriesError extends GroceriesState {
  final String message;

  const GroceriesError(this.message);

  @override
  List<Object> get props => [message];
}
