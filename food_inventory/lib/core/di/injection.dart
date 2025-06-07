import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/storage/data/datasources/storage_remote_datasource.dart';
import '../../features/storage/data/repositories/storage_repository_impl.dart';
import '../../features/storage/domain/repositories/storage_repository.dart';
import '../../features/storage/domain/usecases/get_storages_usecase.dart';
import '../../features/storage/domain/usecases/create_storage_usecase.dart';
import '../../features/storage/domain/usecases/join_storage_usecase.dart';
import '../../features/storage/presentation/bloc/storage_bloc.dart';

import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/get_products_usecase.dart';
import '../../features/product/domain/usecases/create_product_usecase.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  final supabase = Supabase.instance.client;
  getIt.registerSingleton<SupabaseClient>(supabase);
  
  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<SupabaseClient>()),
  );
  
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );
  
  getIt.registerLazySingleton(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt<AuthRepository>()));
  
  getIt.registerFactory(() => AuthBloc(
    loginUseCase: getIt<LoginUseCase>(),
    registerUseCase: getIt<RegisterUseCase>(),
    logoutUseCase: getIt<LogoutUseCase>(),
  ));
  
  // Storage
  getIt.registerLazySingleton<StorageRemoteDataSource>(
    () => StorageRemoteDataSource(getIt<SupabaseClient>()),
  );
  
  getIt.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(getIt<StorageRemoteDataSource>()),
  );
  
  getIt.registerLazySingleton(() => GetStoragesUseCase(getIt<StorageRepository>()));
  getIt.registerLazySingleton(() => CreateStorageUseCase(getIt<StorageRepository>()));
  getIt.registerLazySingleton(() => JoinStorageUseCase(getIt<StorageRepository>()));
  
  getIt.registerFactory(() => StorageBloc(
    getStoragesUseCase: getIt<GetStoragesUseCase>(),
    createStorageUseCase: getIt<CreateStorageUseCase>(),
    joinStorageUseCase: getIt<JoinStorageUseCase>(),
  ));
  
  // Product
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(getIt<SupabaseClient>()),
  );
  
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(getIt<ProductRemoteDataSource>()),
  );
  
  getIt.registerLazySingleton(() => GetProductsUseCase(getIt<ProductRepository>()));
  getIt.registerLazySingleton(() => CreateProductUseCase(getIt<ProductRepository>()));
  
  getIt.registerFactory(() => ProductBloc(
    getProductsUseCase: getIt<GetProductsUseCase>(),
    createProductUseCase: getIt<CreateProductUseCase>(),
  ));
}
