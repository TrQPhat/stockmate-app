import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/bloc/home/home_event.dart';
import 'package:stock_mate/bloc/home/home_state.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/repositories/home_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;
  HomeBloc(this.homeRepository) : super(const HomeState()) {
    on<LoadHomeStats>(_onLoadHomeStats);
  }

  Future<void> _onLoadHomeStats(
    LoadHomeStats event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = getIt<SharedPreferences>();
      final storageId = prefs.getInt(AppConfig.storageIdKey) ?? 0;
      if (storageId == 0) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Không tìm thấy kho hàng. Vui lòng chọn kho hàng.',
        ));
        return;
      }

      // Gọi API từ repository
      final stats = await homeRepository.getHomeStats(storageId);

      emit(state.copyWith(
        totalProducts: stats.totalProducts,
        nearExpiry: stats.nearExpiry,
        expired: stats.expired, // 👈 Thêm dòng này
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
