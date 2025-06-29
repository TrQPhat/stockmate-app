import 'package:go_router/go_router.dart';
import 'package:stock_mate/models/grocery.dart';
import 'package:stock_mate/views/dishes/screen/dishes_screen.dart';
import 'package:stock_mate/views/groceries/views/groceries_page.dart';
import 'package:stock_mate/views/groceries/views/grocery_detail.dart';
import 'package:stock_mate/views/home/views/home_page.dart';
import 'package:stock_mate/views/shopping/views/shopping_detail_page.dart';
import 'package:stock_mate/views/splash/views/splash_screen.dart';
import 'package:stock_mate/views/user/views/user_management_page.dart';
import '../../views/auth/views/login_page.dart';
import '../../views/auth/views/register_page.dart';
import '../../views/storage/views/storage_page.dart';
import '../../views/shopping/views/shopping_page.dart';
import '../../views/statistics/views/statistics_page.dart';

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
        path: '/grocery',
        builder: (context, state) => const GroceriesPage(),
      ),
      GoRoute(
        path: '/grocery-detail',
        builder: (context, state) {
          final grocery = state.extra as Grocery;
          return GroceryDetailPage(grocery: grocery);
        },
      ),
      GoRoute(
        path: '/storage',
        builder: (context, state) => const StoragePage(),
      ),
      GoRoute(
        path: '/shopping',
        builder: (context, state) => const ShoppingPage(),
        routes: [
          GoRoute(
            path: ':listId',
            builder: (context, state) {
              final listId = int.parse(state.pathParameters['listId']!);
              return ShoppingDetailPage(listId: listId);
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
        path: '/dish',
        builder: (context, state) => const DishesScreen(),
      ),
    ],
  );
}
