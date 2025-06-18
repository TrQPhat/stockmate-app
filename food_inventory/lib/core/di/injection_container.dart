import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/features/auth/bloc/auth_bloc.dart';
import 'package:stock_mate/features/shopping/bloc/shopping_bloc.dart';
import 'package:stock_mate/features/shopping/repository/shopping_repository.dart';
import 'package:stock_mate/features/storage/bloc/storage_bloc.dart';
import 'package:stock_mate/features/storage/repository/storage_repository.dart';
import 'package:stock_mate/features/user/bloc/user_management_bloc.dart';
import 'package:stock_mate/features/user/repository/user_management_repository.dart';

import '../../features/auth/repositories/auth_repository.dart';
import '../../features/ingredient/bloc/ingredients_bloc.dart';
import '../../features/ingredient/repositories/ingredients_repository.dart';
import '../../features/recipes/bloc/recipe_bloc.dart';
import '../../features/recipes/repositories/recipe_repository.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';

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
  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<StorageRepository>(
    () => StorageRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<UserManagementRepository>(
    () => UserManagementRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ShoppingRepository>(
    () => ShoppingRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<RecipeRepository>(
    () => RecipeRepository(getIt<DioClient>()),
  );
  // BLoCs
  getIt.registerFactory(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory(() => ProductsBloc(getIt<ProductsRepository>()));
  getIt.registerFactory(() => StorageBloc(getIt<StorageRepository>()));
  getIt.registerFactory(
      () => UserManagementBloc(getIt<UserManagementRepository>()));
  getIt.registerFactory(() => ShoppingBloc(getIt<ShoppingRepository>()));
  getIt.registerFactory(() => RecipeBloc(getIt<RecipeRepository>()));
}
