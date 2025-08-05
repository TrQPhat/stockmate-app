import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/models/dish.dart';
import 'package:stock_mate/repositories/dish_repository.dart';
import 'dish_event.dart';
import 'dish_state.dart';

class DishBloc extends Bloc<DishEvent, DishState> {
  final DishesRepository _repository;

  DishBloc(this._repository) : super(DishInitial()) {
    on<LoadYourDishes>(_onFetchYourDishes);
    on<LoadSuggestDishes>(_onFetchSuggestDishes);
    on<AddDish>(_onAddDish);
    on<UpdateDish>(_onUpdateDish);
    on<DeleteDish>(_onDeleteDish);
    on<ToggleFavoriteDish>(_handleToggleFavoriteDish);
  }

  Future<void> _onFetchYourDishes(
      LoadYourDishes event, Emitter<DishState> emit) async {
    emit(DishLoading());
    try {
      final dishes = await _repository.getDishes();
      emit(DishLoaded(dishes));
    } catch (e) {
      // emit(DishError('Lỗi khi tải danh sách món ăn: $e'));
    }
  }

  Future<void> _onFetchSuggestDishes(
      LoadSuggestDishes event, Emitter<DishState> emit) async {
    emit(DishLoading());
    try {
      final dishes = await _repository.getSuggestedDishes();
      emit(DishLoaded(dishes));
    } catch (e) {
      // emit(DishError('Lỗi khi tải danh sách món ăn: $e'));
    }
  }

  Future<void> _onAddDish(AddDish event, Emitter<DishState> emit) async {
    final currentState = state;
    try {
      final newDish = await _repository.createDish(event.dish);

      if (currentState is DishLoaded) {
        final updatedDishes = List<Dish>.from(currentState.dishes)
          ..insert(0, newDish);
        emit(DishLoaded(updatedDishes));
      }
    } catch (e) {
      emit(DishError('Lỗi khi thêm món ăn: $e'));
    }
  }

  Future<void> _onUpdateDish(UpdateDish event, Emitter<DishState> emit) async {
    final currentState = state;
    print("trạng thái hiện tại: $currentState");
    try {
      final updatedDish = await _repository.updateDish(event.updatedDish);
      if (currentState is DishLoaded) {
        final updatedDishes = currentState.dishes.map((dish) {
          return dish.id == updatedDish.id ? updatedDish : dish;
        }).toList();
        emit(DishLoaded(updatedDishes));
      }
    } catch (e) {
      print("Có lỗi xảy ra ${e.toString()}");
      emit(DishError('Lỗi khi sửa món ăn: $e'));
    }
  }

  Future<void> _onDeleteDish(DeleteDish event, Emitter<DishState> emit) async {
    if (state is DishLoaded) {
      final currentState = state as DishLoaded;
      try {
        await _repository.deleteDish(event.id);
        final updatedDishes =
            currentState.dishes.where((dish) => dish.id != event.id).toList();
        emit(DishLoaded(updatedDishes));
      } catch (e) {
        emit(DishError('Lỗi khi xóa món ăn: $e'));
      }
    }
  }

  Future<void> _handleToggleFavoriteDish(
    ToggleFavoriteDish event,
    Emitter<DishState> emit,
  ) async {
    final currentState = state;
    print('Trạng thái hiện tại: $currentState');
    if (currentState is DishLoaded) {
      try {
        final prefs = getIt<SharedPreferences>();
        final userId = prefs.getInt(AppConfig.userIdKey);
        if (userId == null) return;
        // Gọi repository để lấy trạng thái yêu thích mới
        final isFavorited = await _repository.toggleFavoriteDish(
          userId: userId,
          dishId: event.dishId,
        );

        // Cập nhật món ăn trong danh sách
        final updatedDishes = currentState.dishes.map((dish) {
          if (dish.id == event.dishId) {
            return dish.copyWith(isFavorited: isFavorited);
          }
          return dish;
        }).toList();

        emit(DishLoaded(updatedDishes));
      } catch (e) {
        // emit(DishError("Không thể cập nhật yêu thích: ${e.toString()}"));
      }
    }
  }
}
