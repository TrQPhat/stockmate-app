import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/storage/presentation/bloc/storage_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://tqzznijampovhjmazpgs.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRxenpuaWphbXBvdmhqbWF6cGdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkwNDQ5NjEsImV4cCI6MjA2NDYyMDk2MX0.S_fgHTvOxwuuLVgcT8g1zHIXFEp0taVR0cj4WqR-1sc',
  );
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Setup dependency injection
  await configureDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => getIt<StorageBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Storage Manager',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
