import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stock_mate/bloc/auth/auth_bloc.dart';
import 'package:stock_mate/bloc/category/categories_bloc.dart';
import 'package:stock_mate/bloc/dish/dish_bloc.dart';
import 'package:stock_mate/bloc/shopping-item/shopping_item_bloc.dart';
import 'package:stock_mate/bloc/storage/storage_bloc.dart';
import 'package:stock_mate/bloc/positon/position_bloc.dart';
import 'package:stock_mate/bloc/user/user_bloc.dart';
import 'package:stock_mate/services/refresh_token_service.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'bloc/grocery/groceries_bloc.dart';
import 'bloc/shopping-list/shopping_list_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize dependencies
  await initializeDependencies();
  final tokenRefreshService = TokenRefreshService();
  tokenRefreshService.startAutoRefresh();

  runApp(const StockMateApp());
}

class StockMateApp extends StatelessWidget {
  const StockMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<AuthBloc>()),
            BlocProvider(create: (_) => getIt<GroceriesBloc>()),
            BlocProvider(create: (_) => getIt<StorageBloc>()),
            BlocProvider(create: (_) => getIt<CategoriesBloc>()),
            BlocProvider(create: (_) => getIt<PositionBloc>()),
            BlocProvider(create: (_) => getIt<UserManagementBloc>()),
            BlocProvider(create: (_) => getIt<ShoppingListBloc>()),
            BlocProvider(create: (_) => getIt<ShoppingItemBloc>()),
            BlocProvider(create: (_) => getIt<DishBloc>()),
          ],
          child: MaterialApp.router(
            title: 'Stock Mate',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
