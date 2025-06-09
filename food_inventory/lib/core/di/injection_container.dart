import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/features/auth/bloc/auth_bloc.dart';

import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../../features/auth/repositories/auth_repository.dart';

import '../../features/products/repositories/products_repository.dart';
import '../../features/products/bloc/products_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // DioA
  getIt.registerSingleton<Dio>(Dio());

  // Dio Client
  getIt.registerSingleton<DioClient>(
    DioClient(getIt<Dio>(), baseUrl: AppConfig.fullApiUrl),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepository(getIt<DioClient>()),
  );

  // BLoCs
  getIt.registerFactory(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory(() => ProductsBloc(getIt<ProductsRepository>()));
}
