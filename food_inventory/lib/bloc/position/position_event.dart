part of 'position_bloc.dart';

abstract class PositionEvent extends Equatable {
  const PositionEvent();

  @override
  List<Object?> get props => [];
}

class LoadPosition extends PositionEvent {}

class AddPosition extends PositionEvent {
  final Position position;

  const AddPosition(this.position);

  @override
  List<Object> get props => [position];
}

class UpdatePosition extends PositionEvent {
  final Position position;

  const UpdatePosition(this.position);

  @override
  List<Object> get props => [position];
}

class DeletePosition extends PositionEvent {
  final int positionId;

  const DeletePosition(this.positionId);

  @override
  List<Object> get props => [positionId];
}
