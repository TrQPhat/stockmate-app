import 'package:equatable/equatable.dart';

abstract class WasteStatsEvent extends Equatable {
  const WasteStatsEvent();

  @override
  List<Object> get props => [];
}

class LoadWasteStats extends WasteStatsEvent {}
