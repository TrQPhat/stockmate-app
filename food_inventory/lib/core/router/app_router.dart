import 'package:go_router/go_router.dart';
import 'package:stock_mate/features/home/views/home_page.dart';
import 'package:stock_mate/features/shopping/views/shopping_list_detail_page.dart';
import 'package:stock_mate/features/shopping/views/shopping_page.dart';
import 'package:stock_mate/features/splash/views/splash_screen.dart';
import 'package:stock_mate/features/user/views/user_management_page.dart';

import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/register_page.dart';
import '../../features/ingredient/views/ingredients_page.dart';
import '../../features/recipes/views/add_edit_recipe_page.dart';
import '../../features/recipes/views/recipe_detail_page.dart';
import '../../features/recipes/views/recipe_list_page.dart';
import '../../features/statistics/views/statistics_page.dart';
import '../../features/storage/views/storage_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Main app routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/storage',
        builder: (context, state) => const StoragePage(),
      ),
      GoRoute(
        path: '/shopping',
        builder: (context, state) => const ShoppingListPage(),
        routes: [
          GoRoute(
            path: ':listId',
            builder: (context, state) {
              final listId = state.pathParameters['listId']!;
              return ShoppingListDetailPage(listId: listId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsPage(),
      ),
      GoRoute(
        path: '/user',
        builder: (context, state) => const UserManagementPage(),
      ),
      GoRoute(
        path: '/recipes',
        builder: (context, state) => const RecipeListPage(),
        routes: [
          GoRoute(
            path: 'add', // Sửa thành đường dẫn con
            builder: (context, state) => const AddEditRecipePage(),
          ),
          GoRoute(
            path: ':recipeId', // Sửa thành tham số
            builder: (context, state) {
              final recipeId = state.pathParameters['recipeId']!;
              return RecipeDetailPage(recipeId: recipeId);
            },
          ),
        ],
      ),
    ],
  );
}
