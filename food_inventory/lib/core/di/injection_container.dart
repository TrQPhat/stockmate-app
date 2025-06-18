import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/bloc/auth/auth_bloc.dart';
import 'package:stock_mate/bloc/category/categories_bloc.dart';
import 'package:stock_mate/bloc/tag/position_bloc.dart';
import 'package:stock_mate/repositories/categories_repository.dart';
import 'package:stock_mate/bloc/storage/storage_bloc.dart';
import 'package:stock_mate/repositories/position_repository.dart';
import 'package:stock_mate/repositories/storage_repository.dart';
import 'package:stock_mate/bloc/user/user_bloc.dart';
import 'package:stock_mate/repositories/user_management_repository.dart';
import 'package:stock_mate/repositories/user_repository.dart';

import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../../repositories/auth_repository.dart';

import '../../repositories/ingredients_repository.dart';
import '../../bloc/ingredient/ingredients_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // DioA
  getIt.registerSingleton<Dio>(Dio());

  // Dio Client
  getIt.registerSingleton<DioClient>(
    DioClient(getIt<Dio>(), baseUrl: AppConfig.baseUrl),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<IngredientsRepository>(
    () => IngredientsRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<StorageRepository>(
    () => StorageRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<PositionRepository>(
    () => PositionRepository(getIt<DioClient>()),
  );

  // BLoCs
  getIt.registerFactory(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory(() => IngredientsBloc(getIt<IngredientsRepository>()));
  getIt.registerFactory(() => StorageBloc(getIt<StorageRepository>()));
  getIt.registerFactory(() => UserBloc(getIt<UserMemberRepository>()));
  getIt.registerFactory(() => CategoriesBloc(getIt<CategoriesRepository>()));
  getIt.registerFactory(() => PositionBloc(getIt<PositionRepository>()));
}
