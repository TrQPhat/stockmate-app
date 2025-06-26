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
  }

  Future<void> _onLoadPosition(
    LoadPosition event,
    Emitter<PositionState> emit,
  ) async {
    try {
      final positions = await _repository.getPosition();
      emit(PositionLoaded(positions));
    } catch (e) {
      emit(PositionError(e.toString()));
    }
  }
}
