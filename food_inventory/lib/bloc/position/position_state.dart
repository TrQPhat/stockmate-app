part of 'position_bloc.dart';

abstract class PositionState extends Equatable {
  const PositionState();

  @override
  List<Object?> get props => [];
}

class PositionInitial extends PositionState {}

class PositionLoading extends PositionState {}

class PositionLoaded extends PositionState {
  final List<Position> positions;

  const PositionLoaded(this.positions);

  @override
  List<Object> get props => [positions];
}

class PositionError extends PositionState {
  final String message;

  const PositionError(this.message);

  @override
  List<Object> get props => [message];
}
