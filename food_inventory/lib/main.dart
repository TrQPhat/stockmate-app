import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stock_mate/features/auth/bloc/auth_bloc.dart';
import 'package:stock_mate/features/storage/bloc/storage_bloc.dart';
import 'package:stock_mate/features/user/bloc/user_management_bloc.dart';
import 'package:stock_mate/services/refresh_token_service.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/products/bloc/products_bloc.dart';

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
            BlocProvider(create: (_) => getIt<ProductsBloc>()),
            BlocProvider(create: (_) => getIt<StorageBloc>()),
            BlocProvider(create: (_) => getIt<UserManagementBloc>()),
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
