import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_mate/models/position.dart';
import 'package:stock_mate/repositories/position_repository.dart';

part 'position_event.dart';
part 'position_state.dart';

class PositionBloc extends Bloc<PositionEvent, PositionState> {
  final PositionRepository _repository;

  PositionBloc(this._repository) : super(PositionInitial()) {
    on<LoadPosition>(_onLoadPosition);
    on<AddPosition>(_onAddPosition);
    on<UpdatePosition>(_onUpdatePosition);
    on<DeletePosition>(_onDeletePosition);
  }

  Future<void> _onLoadPosition(
    LoadPosition event,
    Emitter<PositionState> emit,
  ) async {
    emit(PositionLoading());
    try {
      final positions = await _repository.getPosition();
      emit(PositionLoaded(positions));
    } catch (e) {
      emit(PositionError(e.toString()));
    }
  }

  Future<void> _onAddPosition(
    AddPosition event,
    Emitter<PositionState> emit,
  ) async {
    try {
      if (state is PositionLoaded) {
        final current =
            List<Position>.from((state as PositionLoaded).positions);
        final newPosition = await _repository.addPosition(event.position);
        current.insert(0, newPosition);
        emit(PositionLoaded(current));
      } else {
        final positions = await _repository.getPosition();
        emit(PositionLoaded(positions));
      }
    } catch (e) {
      // emit(PositionError('Không thể thêm vị trí: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePosition(
    UpdatePosition event,
    Emitter<PositionState> emit,
  ) async {
    try {
      if (state is PositionLoaded) {
        final current =
            List<Position>.from((state as PositionLoaded).positions);
        final updatedPosition =
            await _repository.updatePosition(event.position);
        final idx = current.indexWhere((p) => p.id == updatedPosition.id);
        if (idx != -1) {
          current[idx] = updatedPosition;
        }
        emit(PositionLoaded(current));
      } else {
        final positions = await _repository.getPosition();
        emit(PositionLoaded(positions));
      }
    } catch (e) {
      // emit(PositionError('Không thể cập nhật vị trí: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePosition(
    DeletePosition event,
    Emitter<PositionState> emit,
  ) async {
    try {
      if (state is PositionLoaded) {
        final current =
            List<Position>.from((state as PositionLoaded).positions);
        await _repository.deletePosition(event.positionId);
        current.removeWhere((p) => p.id == event.positionId);
        emit(PositionLoaded(current));
      } else {
        final positions = await _repository.getPosition();
        emit(PositionLoaded(positions));
      }
    } catch (e) {
      // emit(PositionError('Không thể xóa vị trí: ${e.toString()}'));
    }
  }
}
