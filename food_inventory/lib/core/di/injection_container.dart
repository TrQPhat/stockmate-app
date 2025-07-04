import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/bloc/auth/auth_bloc.dart';
import 'package:stock_mate/bloc/category/categories_bloc.dart';
import 'package:stock_mate/bloc/dish/dish_bloc.dart';
import 'package:stock_mate/bloc/grocery/groceries_bloc.dart';
import 'package:stock_mate/bloc/message/message_bloc.dart';
import 'package:stock_mate/bloc/shopping-item/shopping_item_bloc.dart';
import 'package:stock_mate/bloc/positon/position_bloc.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/network/dio_client.dart';
import 'package:stock_mate/repositories/auth_repository.dart';
import 'package:stock_mate/repositories/categories_repository.dart';
import 'package:stock_mate/bloc/storage/storage_bloc.dart';
import 'package:stock_mate/repositories/dish_repository.dart';
import 'package:stock_mate/repositories/groceries_repository.dart';
import 'package:stock_mate/repositories/message_reporitory.dart';
import 'package:stock_mate/repositories/position_repository.dart';
import 'package:stock_mate/repositories/shopping_item_repository.dart';
import 'package:stock_mate/repositories/storage_repository.dart';
import 'package:stock_mate/bloc/user/user_bloc.dart';
import 'package:stock_mate/repositories/user_management_repository.dart';
import 'package:stock_mate/bloc/shopping-list/shopping_list_bloc.dart';
import 'package:stock_mate/repositories/shopping_list_repository.dart';
import 'package:stock_mate/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  //Supabase client
  getIt.registerSingleton<SupabaseClient>(SupabaseService().client);

  //env
  await dotenv.load(fileName: ".env");

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<StorageRepository>(
    () => StorageRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<PositionRepository>(
    () => PositionRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ShoppingListRepository>(
    () => ShoppingListRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<GroceriesRepository>(
    () => GroceriesRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ShoppingItemRepository>(
    () => ShoppingItemRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<DishesRepository>(
    () => DishesRepository(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<MessageRepository>(
    () => MessageRepository(getIt<DioClient>()),
  );

  // BLoCs
  getIt.registerFactory(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory(() => GroceriesBloc(getIt<GroceriesRepository>()));
  getIt.registerFactory(() => StorageBloc(getIt<StorageRepository>()));
  getIt
      .registerFactory(() => UserManagementBloc(getIt<UserMemberRepository>()));
  getIt
      .registerFactory(() => ShoppingListBloc(getIt<ShoppingListRepository>()));
  getIt.registerFactory(() => CategoriesBloc(getIt<CategoriesRepository>()));
  getIt.registerFactory(() => PositionBloc(getIt<PositionRepository>()));
  getIt
      .registerFactory(() => ShoppingItemBloc(getIt<ShoppingItemRepository>()));
  getIt.registerFactory(() => DishBloc(getIt<DishesRepository>()));
  getIt.registerFactory(() => MessageBloc(getIt<MessageRepository>()));
}
