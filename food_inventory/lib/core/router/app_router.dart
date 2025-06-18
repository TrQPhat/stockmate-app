import 'package:go_router/go_router.dart';
import 'package:stock_mate/views/home/views/home_page.dart';
import 'package:stock_mate/views/splash/views/splash_screen.dart';
import 'package:stock_mate/views/user/views/user_management_page.dart';
import '../../views/auth/views/login_page.dart';
import '../../views/auth/views/register_page.dart';
import '../../views/ingredient/views/ingredients_page.dart';
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
        path: '/products',
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: '/storage',
        builder: (context, state) => const StoragePage(),
      ),
      GoRoute(
        path: '/shopping',
        builder: (context, state) => const ShoppingPage(),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsPage(),
      ),
      GoRoute(
        path: '/user',
        builder: (context, state) => const UserManagementPage(),
      ),
    ],
  );
}
