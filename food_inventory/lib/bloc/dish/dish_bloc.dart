import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/repositories/dish_repository.dart';
import 'dish_event.dart';
import 'dish_state.dart';

class DishBloc extends Bloc<DishEvent, DishState> {
  final DishesRepository _repository;

  DishBloc(this._repository) : super(DishInitial()) {
    on<LoadYourDishes>(_onFetchYourDishes);
    on<LoadSuggestDishes>(_onFetchSuggestDishes);
  }

  Future<void> _onFetchYourDishes(
      LoadYourDishes event, Emitter<DishState> emit) async {
    emit(DishLoading());
    try {
      final dishes = await _repository.getDishes();
      emit(DishLoaded(dishes));
    } catch (e) {
      emit(DishError('Lỗi khi tải danh sách món ăn: $e'));
    }
  }

  Future<void> _onFetchSuggestDishes(
      LoadSuggestDishes event, Emitter<DishState> emit) async {
    emit(DishLoading());
    try {
      final dishes = await _repository.getSuggestedDishes();
      emit(DishLoaded(dishes));
    } catch (e) {
      emit(DishError('Lỗi khi tải danh sách món ăn: $e'));
    }
  }
}
