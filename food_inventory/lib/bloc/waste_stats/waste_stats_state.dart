import 'package:equatable/equatable.dart';
import 'package:stock_mate/models/waste_stats.dart';

abstract class WasteStatsState extends Equatable {
  const WasteStatsState();

  @override
  List<Object?> get props => [];
}

class WasteStatsInitial extends WasteStatsState {}

class WasteStatsLoading extends WasteStatsState {}

class WasteStatsLoaded extends WasteStatsState {
  final WasteStats stats;

  const WasteStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class WasteStatsError extends WasteStatsState {
  final String message;

  const WasteStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
