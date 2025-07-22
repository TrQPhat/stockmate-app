import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/repositories/stats_repository.dart';
import 'waste_stats_event.dart';
import 'waste_stats_state.dart';

class WasteStatsBloc extends Bloc<WasteStatsEvent, WasteStatsState> {
  final StatsRepository repository;

  WasteStatsBloc(this.repository) : super(WasteStatsInitial()) {
    on<LoadWasteStats>(_onLoadWasteStats);
  }

  Future<void> _onLoadWasteStats(
    LoadWasteStats event,
    Emitter<WasteStatsState> emit,
  ) async {
    emit(WasteStatsLoading());

    try {
      final stats = await repository.getWasteStats();
      emit(WasteStatsLoaded(stats));
    } catch (e) {
      emit(WasteStatsError(e.toString()));
    }
  }
}
