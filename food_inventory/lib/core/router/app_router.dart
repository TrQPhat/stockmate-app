import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/storage/presentation/pages/storage_list_page.dart';
import '../../features/storage/presentation/pages/storage_detail_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/storages',
        builder: (context, state) => const StorageListPage(),
      ),
      GoRoute(
        path: '/storage/:id',
        builder: (context, state) => StorageDetailPage(
          storageId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/storage/:id/products',
        builder: (context, state) => ProductListPage(
          storageId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/storage/:id/add-product',
        builder: (context, state) => AddProductPage(
          storageId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
